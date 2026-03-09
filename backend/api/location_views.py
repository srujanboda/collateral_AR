from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
import requests
import os

class PincodeLookupView(APIView):
    """
    Acts as a proxy to Zipcodebase API.
    Keeps the API key secure on the backend.
    """
    def get(self, request):
        pincode = request.query_params.get('pincode')
        country = request.query_params.get('country', 'IN') # Default to India

        if not pincode:
            return Response({"error": "Pincode is required"}, status=status.HTTP_400_BAD_REQUEST)

        api_key = os.getenv('ZIPCODEBASE_API_KEY')
        if not api_key:
            return Response({"error": "API Key not configured on server"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        url = f"https://app.zipcodebase.com/api/v1/search?apikey={api_key}&codes={pincode}&country={country}"

        try:
            response = requests.get(url)
            data = response.json()

            # Zipcodebase returns a dictionary where keys are the codes
            results = data.get('results', {})
            
            # Handle case where API returns empty list [] instead of {}
            if isinstance(results, list):
                if not results:
                    results = {}
                else:
                    print(f"Unexpected list results: {results}")
                    # If it's a list with items, we can't use .get(pincode)
                    # This might happen if the API format changes
            
            if not isinstance(results, dict):
                 print(f"Invalid results format: {type(results)} - {results}")
                 return Response({"error": "External API returned invalid format"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            pincode_results = results.get(pincode, [])

            if not pincode_results:
                return Response({"error": "No location found for this pincode"}, status=status.HTTP_404_NOT_FOUND)

            # Standardize the response for our frontend
            # We take the unique states/districts and a list of all names (cities)
            cities = []
            for item in pincode_results:
                cities.append(item.get('city', item.get('province')))
            
            # Remove duplicates and empty values
            cities = sorted(list(set(filter(None, cities))))
            
            first = pincode_results[0]
            
            return Response({
                "status": "Success",
                "data": {
                    "state": first.get('state', '').strip(),
                    "district": first.get('province', '').strip(),
                    "country": first.get('country_code', country).strip(),
                    "cities": cities
                }
            })

        except Exception as e:
            print(f"Location Lookup Error: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
