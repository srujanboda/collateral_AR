import json
from channels.generic.websocket import AsyncWebsocketConsumer

class ApplicantConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.group_name = 'applicants'
        
        # Join applicants group
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        await self.accept()
        print(f"WebSocket connected: {self.channel_name} to group {self.group_name}")

    async def disconnect(self, close_code):
        # Leave applicants group
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )
        print(f"WebSocket disconnected: {self.channel_name}")

    # Receive message from room group
    async def applicant_update(self, event):
        message = event['message']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'type': 'applicant_update',
            'message': message
        }))
