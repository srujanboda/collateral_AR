from . import application_service, email_service, user_service
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from .serializers import ApplicationCreateSerializer
from django.views.decorators.csrf import csrf_exempt

from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    def post(self, request):
        try:
            from .serializers import LoginSerializer
            serializer = LoginSerializer(data=request.data)
            
            if serializer.is_valid():
                username = serializer.validated_data['username']
                password = serializer.validated_data['password']
                
                user = user_service.authenticate_user(username, password)
                if user:
                    return Response({
                        'message': 'Login successful',
                        'user': {
                            'username': user['username'],
                            'role': user.get('role', 'Admin'),
                        }
                    }, status=status.HTTP_200_OK)
                else:
                    return Response({'error': 'Invalid username or password'}, status=status.HTTP_401_UNAUTHORIZED)
            
            return Response({'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({
                'error': 'Internal Server Error during login',
                'details': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#---------------------applicant create----------------------#
class ApplicationCreateView(APIView):
    def post(self, request):
        serializer = ApplicationCreateSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response({'errors': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            # data is now clean and validated
            new_app = application_service.create_application(serializer.validated_data)
            
            # Send the email with the journey-1 link in the background
            from . import email_service
            
            journey_url = f"{settings.JOURNEY_URL}?perfios_id={new_app['perfios_id']}"
            email_service.send_application_link_and_update_status(
                new_app['perfios_id'],
                new_app['email'], 
                new_app['name'], 
                journey_url
            )
            
            # Return immediate response. email_status will be 'Pending' initially.
            return Response({
                'message': 'Application created successfully. Email is being sent in the background.',
                'email_status': 'Pending',
                'application': new_app
            }, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

#---------------------applicant list----------------------#
class ApplicationListView(APIView):
    def get(self, request):
        applications = application_service.list_applications()
        return Response(applications, status=status.HTTP_200_OK)

#---------------------single applicant get by id----------------------#
class ApplicationDetailView(APIView):
    def get(self, request, perfios_id):
        applicant = application_service.get_application_by_id(perfios_id)
        if applicant:
            return Response(applicant, status=status.HTTP_200_OK)
        return Response({'error': 'Application not found'}, status=status.HTTP_404_NOT_FOUND)

#---------------------applicant update----------------------#
class ApplicationUpdateView(APIView):
    def patch(self, request):
        perfios_id = request.data.get("perfios_id")
        if not perfios_id:
            return Response({'error': 'perfios_id is required to update'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Remove perfios_id from updates to prevent changing it
        updates = request.data.copy()
        del updates["perfios_id"]
        
        if application_service.update_application(perfios_id, updates):
            return Response({'message': 'Application updated successfully'}, status=status.HTTP_200_OK)
        return Response({'error': 'Application not found or no changes made'}, status=status.HTTP_404_NOT_FOUND)

#---------------------applicant delete----------------------#
class ApplicationDeleteView(APIView):
    def delete(self, request):
        perfios_id = request.data.get("perfios_id")
        if not perfios_id:
            return Response({'error': 'perfios_id is required to delete'}, status=status.HTTP_400_BAD_REQUEST)
        
        success, message, deleted_files_count = application_service.cascade_delete_application(perfios_id)
        
        if success:
            return Response({
                'message': message,
                'deleted_files': deleted_files_count
            }, status=status.HTTP_200_OK)
        
        return Response({'error': message}, status=status.HTTP_404_NOT_FOUND if message == "Application not found" else status.HTTP_500_INTERNAL_SERVER_ERROR)




#--------------------Documentuploading---------------------------#
@method_decorator(csrf_exempt, name='dispatch')
class DocumentUploadView(APIView):
    def post(self, request):
        perfios_id = request.data.get('perfios_id')
        step_id = request.data.get('step_id')
        files = request.FILES.getlist('files')

        if not perfios_id or not step_id or not files:
            return Response({'error': 'perfios_id, step_id, and files are required'}, status=status.HTTP_400_BAD_REQUEST)

        result, error = application_service.handle_document_upload(perfios_id, step_id, files)
        
        if error:
            return Response({'error': error}, status=status.HTTP_404_NOT_FOUND)

        return Response(result, status=status.HTTP_201_CREATED)


#--------------------Journey Completion---------------------------#
class ApplicationCompleteView(APIView):
    def post(self, request):
        perfios_id = request.data.get('perfios_id')
        if not perfios_id:
            return Response({'error': 'perfios_id is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        success, message = application_service.complete_application(perfios_id)
        
        if success:
            app_data = application_service.get_application_by_id(perfios_id)
            if app_data and app_data.get('email'):
                from . import email_service
                email_service.send_document_upload_success(app_data['email'], app_data.get('name', 'Applicant'))

            return Response({'message': message}, status=status.HTTP_200_OK)
        return Response({'error': message}, status=status.HTTP_404_NOT_FOUND)


#---------------------User Management Views----------------------#
class UserListView(APIView):
    def get(self, request):
        users = user_service.list_users()
        return Response(users, status=status.HTTP_200_OK)

class UserCreateView(APIView):
    def post(self, request):
        email = request.data.get('email')
        name = request.data.get('name')
        organization = request.data.get('organization')
        customer = request.data.get('customer')
        role = request.data.get('role', 'Admin')

        if not email or not name or not customer:
            return Response({'error': 'Email, Name, and Customer are required'}, status=status.HTTP_400_BAD_REQUEST)

        # Generate random password
        password = user_service.generate_random_password()
        
        user, error = user_service.create_user(email, password, name, organization, customer, role)
        
        if error:
            return Response({'error': error}, status=status.HTTP_400_BAD_REQUEST)

        # Send email with credentials in the background
        from . import email_service
        email_service.send_user_credentials(email, name, password)
        
        return Response({
            'message': 'User created successfully. Credentials are being sent via email.',
            'user': {
                'username': user['username'],
                'name': user['name'],
                'role': user['role'],
                'temp_password': password
            }
        }, status=status.HTTP_201_CREATED)

class UserUpdateView(APIView):
    def patch(self, request):
        username = request.data.get('username')
        if not username:
            return Response({'error': 'username is required to update'}, status=status.HTTP_400_BAD_REQUEST)
        
        updates = request.data.copy()
        if "username" in updates:
            del updates["username"]
        
        if user_service.update_user(username, updates):
            return Response({'message': 'User updated successfully'}, status=status.HTTP_200_OK)
        return Response({'error': 'User not found or no changes made'}, status=status.HTTP_404_NOT_FOUND)

class UserDeleteView(APIView):
    def delete(self, request):
        username = request.data.get('username')
        if not username:
            return Response({'error': 'username is required to delete'}, status=status.HTTP_400_BAD_REQUEST)
        
        if user_service.delete_user(username):
            return Response({'message': 'User deleted successfully'}, status=status.HTTP_200_OK)
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

#---------------------Field Media Upload (Flutter App)----------------------#
class MediaUploadView(APIView):
    def post(self, request):
        perfios_id = request.data.get('perfios_id')
        email = request.data.get('email')
        files = request.FILES.getlist('files')
        remarks = request.data.get('remarks')
        signature = request.FILES.get('signature')
        
        # Location fields
        submission_address = request.data.get('submission_address')
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')

        if (not perfios_id and not email) or not files:
            return Response(
                {'error': 'Either perfios_id or email is required, along with files'},
                status=status.HTTP_400_BAD_REQUEST
            )

        result, error = application_service.handle_media_upload(
            files,
            perfios_id=perfios_id,
            email=email,
            submission_address=submission_address,
            latitude=latitude,
            longitude=longitude,
            remarks=remarks,
            signature_file=signature
        )

        if error:
            return Response({'error': error}, status=status.HTTP_404_NOT_FOUND)

        return Response(result, status=status.HTTP_201_CREATED)


class ChangePasswordView(APIView):
    def post(self, request):
        username = request.data.get('username')
        current_password = request.data.get('current_password')
        new_password = request.data.get('new_password')

        if not username or not current_password or not new_password:
            return Response({'error': 'All fields are required'}, status=status.HTTP_400_BAD_REQUEST)

        user = user_service.authenticate_user(username, current_password)
        if not user:
            return Response({'error': 'Incorrect current password'}, status=status.HTTP_401_UNAUTHORIZED)

        if user_service.update_password(username, new_password):
            return Response({'message': 'Password updated successfully'}, status=status.HTTP_200_OK)
        return Response({'error': 'Failed to update password'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

