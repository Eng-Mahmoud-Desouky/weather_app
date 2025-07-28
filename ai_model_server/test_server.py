#!/usr/bin/env python3
"""
Test script for the Flask AI Model Server.

This script tests the Flask server endpoints to ensure they work correctly
with the trained model.
"""

import requests
import json
import time

def test_server():
    """
    Test the Flask server endpoints.
    """
    base_url = "http://127.0.0.1:5000"
    
    print("🧪 Testing Flask AI Model Server")
    print("=" * 50)
    
    # Test health endpoint
    print("\n1. Testing Health Endpoint...")
    try:
        response = requests.get(f"{base_url}/health", timeout=5)
        if response.status_code == 200:
            health_data = response.json()
            print(f"✅ Health Check: {health_data}")
        else:
            print(f"❌ Health Check Failed: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Health Check Error: {e}")
        print("Make sure the Flask server is running: python app.py")
        return False
    
    # Test prediction endpoint
    print("\n2. Testing Prediction Endpoint...")
    
    test_cases = [
        {
            "name": "Sunny, mild, normal humidity",
            "features": [0, 1, 0, 1, 1],
            "expected": "suitable"
        },
        {
            "name": "Rainy, mild, normal humidity", 
            "features": [1, 0, 0, 1, 1],
            "expected": "not suitable"
        },
        {
            "name": "Sunny, hot, normal humidity",
            "features": [0, 1, 1, 0, 1],
            "expected": "suitable"
        },
        {
            "name": "Cloudy, cold, extreme humidity",
            "features": [0, 0, 0, 0, 0],
            "expected": "not suitable"
        }
    ]
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n   Test {i}: {test_case['name']}")
        print(f"   Features: {test_case['features']}")
        
        try:
            payload = {"features": test_case["features"]}
            response = requests.post(
                f"{base_url}/predict",
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                prediction = result.get("prediction", -1)
                suitable = result.get("suitable_for_training", False)
                confidence = result.get("confidence", "unknown")
                message = result.get("message", "")
                
                print(f"   ✅ Prediction: {prediction}")
                print(f"   ✅ Suitable: {suitable}")
                print(f"   ✅ Confidence: {confidence}")
                print(f"   ✅ Message: {message}")
                
                # Verify expected result
                if test_case["expected"] == "suitable" and suitable:
                    print(f"   ✅ Expected result: PASS")
                elif test_case["expected"] == "not suitable" and not suitable:
                    print(f"   ✅ Expected result: PASS")
                else:
                    print(f"   ⚠️  Expected result: FAIL (expected {test_case['expected']})")
                    
            else:
                print(f"   ❌ Request Failed: {response.status_code}")
                print(f"   ❌ Response: {response.text}")
                
        except requests.exceptions.RequestException as e:
            print(f"   ❌ Request Error: {e}")
            return False
    
    print("\n" + "=" * 50)
    print("✅ Server testing completed!")
    return True

def test_invalid_requests():
    """
    Test invalid requests to ensure proper error handling.
    """
    base_url = "http://127.0.0.1:5000"
    
    print("\n🧪 Testing Error Handling")
    print("=" * 50)
    
    # Test invalid feature count
    print("\n1. Testing invalid feature count...")
    try:
        payload = {"features": [0, 1, 0]}  # Only 3 features instead of 5
        response = requests.post(
            f"{base_url}/predict",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        
        if response.status_code == 400:
            print("✅ Correctly rejected invalid feature count")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Should have rejected invalid features: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request Error: {e}")
    
    # Test missing features
    print("\n2. Testing missing features...")
    try:
        payload = {}  # No features
        response = requests.post(
            f"{base_url}/predict",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        
        if response.status_code == 400:
            print("✅ Correctly rejected missing features")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Should have rejected missing features: {response.status_code}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request Error: {e}")

if __name__ == "__main__":
    print("🚀 Starting Flask Server Tests")
    print("Make sure the Flask server is running with: python app.py")
    print("Waiting 3 seconds for server to be ready...")
    time.sleep(3)
    
    success = test_server()
    if success:
        test_invalid_requests()
        print("\n🎉 All tests completed!")
    else:
        print("\n❌ Basic tests failed. Please check the server.")
