import threading
import os
from django.conf import settings
from django.core.mail import send_mail

def _send_email_via_smtp(to_email, subject, message):
    """Send email using Django's configured SMTP backend."""
    try:
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[to_email],
            fail_silently=False,
        )
        print(f"Email sent successfully to {to_email}")
        return True, ""
    except Exception as e:
        print(f"Error sending email via SMTP: {e}")
        return False, str(e)

def send_application_link(email, name, journey_url):
    subject = "Application Created Successfully"
    message = f"""Hi {name},

Your application has been successfully created.

To proceed with the next steps of the process, please upload your documents using the link below:
{journey_url}

Thank you!
"""
    return _send_email_via_smtp(email, subject, message)

def _send_app_link_thread(perfios_id, email, name, journey_url):
    """Internal function to be run in a thread."""
    from . import application_service
    email_sent, error_msg = send_application_link(email, name, journey_url)
    email_status_val = 'Sent' if email_sent else f'Failed: {error_msg}'
    application_service.update_application(perfios_id, {'email_status': email_status_val})

def send_application_link_and_update_status(perfios_id, email, name, journey_url):
    """Starts a background thread to send application link and update status."""
    thread = threading.Thread(
        target=_send_app_link_thread,
        args=(perfios_id, email, name, journey_url)
    )
    thread.daemon = True
    thread.start()
    return True

def send_user_credentials(email, name, password):
    subject = "Your Admin Portal Credentials"
    message = f"""Hi {name},

An account has been created for you on the Admin Portal. Here are your login credentials:

Username: {email}
Password: {password}

You can log in at: {settings.ADMIN_PORTAL_URL}

For security reasons, we recommend changing your password after your first login in the Profile section.

Thank you!
"""
    def _send_email():
        _send_email_via_smtp(email, subject, message)

    thread = threading.Thread(target=_send_email)
    thread.daemon = True
    thread.start()
    return True

def send_document_upload_success(email, name):
    subject = "Documents Uploaded Successfully"
    message = f"""Hi {name},

We have successfully received your uploaded documents.

Our team will review them shortly. We will notify you if any further action is required on your part.

Thank you for your cooperation!
"""
    def _send_email():
        _send_email_via_smtp(email, subject, message)

    thread = threading.Thread(target=_send_email)
    thread.daemon = True
    thread.start()
    return True
