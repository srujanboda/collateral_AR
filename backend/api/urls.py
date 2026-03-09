from django.urls import path
from .views import (
    LoginView,
    ApplicationCreateView,
    ApplicationListView,
    ApplicationUpdateView,
    ApplicationDeleteView,
    ApplicationDetailView,
    DocumentUploadView,
    ApplicationCompleteView,
    MediaUploadView,
    UserListView,
    UserCreateView,
    UserUpdateView,
    UserDeleteView,
    ChangePasswordView
)

urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    
    # Application endpoints
    path('application/create/', ApplicationCreateView.as_view(), name='application_create'),
    path('application/list/', ApplicationListView.as_view(), name='application_list'),
    path('application/update/', ApplicationUpdateView.as_view(), name='application_update'),
    path('application/delete/', ApplicationDeleteView.as_view(), name='application_delete'),
    path('application/upload-document/', DocumentUploadView.as_view(), name='application_upload_document'),
    path('application/complete-journey/', ApplicationCompleteView.as_view(), name='application_complete_journey'),
    path('application/upload-media/', MediaUploadView.as_view(), name='application_upload_media'),
    path('application/<str:perfios_id>/', ApplicationDetailView.as_view(), name='application_detail'),
    
    
    # Manage user endpoints
    path('user/list/', UserListView.as_view(), name='user_list'),
    path('user/create/', UserCreateView.as_view(), name='user_create'),
    path('user/update/', UserUpdateView.as_view(), name='user_update'),
    path('user/delete/', UserDeleteView.as_view(), name='user_delete'),
    path('user/change-password/', ChangePasswordView.as_view(), name='change_password'),
]
