from rest_framework import serializers
import re

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField()

    def validate_username(self, value):
        if '@' not in value:
            raise serializers.ValidationError('Username must contain "@"')
        if value != value.lower():
            raise serializers.ValidationError('Username must be in all small letters')
        return value

    def validate_password(self, value):
        if len(value) <= 6:
            raise serializers.ValidationError('Password must be more than 6 characters long')
        if not any(c.isupper() for c in value):
            raise serializers.ValidationError('Password must contain at least one capital letter')
        if not any(c.isdigit() for c in value):
            raise serializers.ValidationError('Password must contain at least one digit')
        return value

class ApplicationCreateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    phone_number = serializers.CharField(max_length=20)
    # Location fields
    address = serializers.CharField(max_length=500)
    pincode = serializers.CharField(max_length=10)
    city = serializers.CharField(max_length=100)
    state = serializers.CharField(max_length=100)
    district = serializers.CharField(max_length=100)
    country = serializers.CharField(max_length=100)
