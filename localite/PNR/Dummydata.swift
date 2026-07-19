//
//  Dummydata.swift
//  localite
//
//  Created by ANOOP on 19/07/26.
//

import Foundation

let dummyJSON = """
{
  "journeys": [
    {
      "pnr": "1234567890",
      "trainName": "Rajdhani Express",
      "trainNumber": "12951",
      "stations": [
        { "name": "New Delhi", "code": "NDLS", "arrivalTime": "18 Jul, 4:00 PM", "latitude": 28.6139, "longitude": 77.2090 },
        { "name": "Mathura Junction", "code": "MTJ", "arrivalTime": "18 Jul, 5:15 PM", "latitude": 27.4924, "longitude": 77.6737 },
        { "name": "Agra Cantt", "code": "AGC", "arrivalTime": "18 Jul, 6:00 PM", "latitude": 27.1559, "longitude": 77.9922 },
        { "name": "Gwalior Junction", "code": "GWL", "arrivalTime": "18 Jul, 7:28 PM", "latitude": 26.2183, "longitude": 78.1828 },
        { "name": "Jhansi Junction", "code": "VGLJ", "arrivalTime": "18 Jul, 8:55 PM", "latitude": 25.4484, "longitude": 78.5685 },
        { "name": "Bhopal Junction", "code": "BPL", "arrivalTime": "18 Jul, 11:30 PM", "latitude": 23.2599, "longitude": 77.4126 },
        { "name": "Itarsi Junction", "code": "ET", "arrivalTime": "19 Jul, 1:15 AM", "latitude": 22.6119, "longitude": 77.7610 },
        { "name": "Jalgaon Junction", "code": "JL", "arrivalTime": "19 Jul, 5:30 AM", "latitude": 21.0077, "longitude": 75.5626 },
        { "name": "Nasik Road", "code": "NK", "arrivalTime": "19 Jul, 8:15 AM", "latitude": 19.9875, "longitude": 73.8341 },
        { "name": "Mumbai Central", "code": "MMCT", "arrivalTime": "19 Jul, 11:00 AM", "latitude": 18.9696, "longitude": 72.8193 }
      ]
    },
    {
      "pnr": "2345678901",
      "trainName": "Shatabdi Express",
      "trainNumber": "12007",
      "stations": [
        { "name": "Bangalore City", "code": "SBC", "arrivalTime": "20 Jul, 6:00 AM", "latitude": 12.9779, "longitude": 77.5668 },
        { "name": "Bangalore Cantt", "code": "BNC", "arrivalTime": "20 Jul, 6:10 AM", "latitude": 12.9937, "longitude": 77.5979 },
        { "name": "Krishnarajapuram", "code": "KJM", "arrivalTime": "20 Jul, 6:25 AM", "latitude": 13.0016, "longitude": 77.6746 },
        { "name": "Bangarapet", "code": "BWT", "arrivalTime": "20 Jul, 7:15 AM", "latitude": 12.9963, "longitude": 78.1963 },
        { "name": "Jolarpettai", "code": "JTJ", "arrivalTime": "20 Jul, 8:40 AM", "latitude": 12.5516, "longitude": 78.5714 },
        { "name": "Katpadi", "code": "KPD", "arrivalTime": "20 Jul, 9:55 AM", "latitude": 12.9760, "longitude": 79.1378 },
        { "name": "Arakkonam", "code": "AJJ", "arrivalTime": "20 Jul, 10:45 AM", "latitude": 13.0850, "longitude": 79.6644 },
        { "name": "Chennai Central", "code": "MAS", "arrivalTime": "20 Jul, 11:30 AM", "latitude": 13.0827, "longitude": 80.2707 }
      ]
    },
    {
      "pnr": "3456789012",
      "trainName": "Howrah Express",
      "trainNumber": "12810",
      "stations": [
        { "name": "Howrah", "code": "HWH", "arrivalTime": "21 Jul, 8:00 AM", "latitude": 22.5830, "longitude": 88.3378 },
        { "name": "Barddhaman", "code": "BWN", "arrivalTime": "21 Jul, 9:15 AM", "latitude": 23.2324, "longitude": 87.8615 },
        { "name": "Durgapur", "code": "DGR", "arrivalTime": "21 Jul, 10:10 AM", "latitude": 23.5204, "longitude": 87.3119 },
        { "name": "Asansol", "code": "ASN", "arrivalTime": "21 Jul, 11:00 AM", "latitude": 23.6823, "longitude": 86.9859 },
        { "name": "Dhanbad", "code": "DHN", "arrivalTime": "21 Jul, 12:15 PM", "latitude": 23.7957, "longitude": 86.4304 },
        { "name": "Gaya Junction", "code": "GAYA", "arrivalTime": "21 Jul, 2:30 PM", "latitude": 24.7955, "longitude": 85.0002 },
        { "name": "Dehri On Sone", "code": "DOS", "arrivalTime": "21 Jul, 3:45 PM", "latitude": 24.9126, "longitude": 84.1812 },
        { "name": "Sasaram", "code": "SSM", "arrivalTime": "21 Jul, 4:10 PM", "latitude": 24.9490, "longitude": 84.0321 },
        { "name": "Pt. Deen Dayal Upadhyaya", "code": "DDU", "arrivalTime": "21 Jul, 6:00 PM", "latitude": 25.2783, "longitude": 83.1189 },
        { "name": "Patna Junction", "code": "PNBE", "arrivalTime": "21 Jul, 9:30 PM", "latitude": 25.6025, "longitude": 85.1382 }
      ]
    },
    {
      "pnr": "4567890123",
      "trainName": "Pune Express",
      "trainNumber": "11019",
      "stations": [
        { "name": "Hyderabad Deccan", "code": "HYB", "arrivalTime": "22 Jul, 1:00 PM", "latitude": 17.3916, "longitude": 78.4688 },
        { "name": "Begumpet", "code": "BMT", "arrivalTime": "22 Jul, 1:15 PM", "latitude": 17.4398, "longitude": 78.4608 },
        { "name": "Vikarabad", "code": "VKB", "arrivalTime": "22 Jul, 2:30 PM", "latitude": 17.3340, "longitude": 77.9042 },
        { "name": "Tandur", "code": "TDU", "arrivalTime": "22 Jul, 3:15 PM", "latitude": 17.2575, "longitude": 77.5878 },
        { "name": "Wadi", "code": "WADI", "arrivalTime": "22 Jul, 4:45 PM", "latitude": 17.0267, "longitude": 76.9933 },
        { "name": "Kalaburagi", "code": "KLBG", "arrivalTime": "22 Jul, 5:30 PM", "latitude": 17.3297, "longitude": 76.8343 },
        { "name": "Solapur", "code": "SUR", "arrivalTime": "22 Jul, 7:15 PM", "latitude": 17.6749, "longitude": 75.8943 },
        { "name": "Kurduvadi", "code": "KWV", "arrivalTime": "22 Jul, 8:40 PM", "latitude": 18.0838, "longitude": 75.4385 },
        { "name": "Daund Junction", "code": "DD", "arrivalTime": "22 Jul, 10:15 PM", "latitude": 18.4552, "longitude": 74.5772 },
        { "name": "Pune Junction", "code": "PUNE", "arrivalTime": "22 Jul, 11:45 PM", "latitude": 18.5284, "longitude": 73.8739 }
      ]
    },
    {
      "pnr": "5678901234",
      "trainName": "Ahmedabad Passenger",
      "trainNumber": "59439",
      "stations": [
        { "name": "Ahmedabad Junction", "code": "ADI", "arrivalTime": "23 Jul, 6:00 AM", "latitude": 23.0267, "longitude": 72.5976 },
        { "name": "Mahesana", "code": "MSH", "arrivalTime": "23 Jul, 7:15 AM", "latitude": 23.5855, "longitude": 72.3688 },
        { "name": "Palanpur", "code": "PNU", "arrivalTime": "23 Jul, 8:45 AM", "latitude": 24.1724, "longitude": 72.4346 },
        { "name": "Abu Road", "code": "ABR", "arrivalTime": "23 Jul, 9:55 AM", "latitude": 24.4764, "longitude": 72.7844 },
        { "name": "Falna", "code": "FA", "arrivalTime": "23 Jul, 11:30 AM", "latitude": 25.2319, "longitude": 73.2384 },
        { "name": "Marwar Junction", "code": "MJ", "arrivalTime": "23 Jul, 12:45 PM", "latitude": 25.7289, "longitude": 73.6186 },
        { "name": "Ajmer Junction", "code": "AII", "arrivalTime": "23 Jul, 3:15 PM", "latitude": 26.4521, "longitude": 74.6399 },
        { "name": "Kishangarh", "code": "KSG", "arrivalTime": "23 Jul, 4:00 PM", "latitude": 26.5744, "longitude": 74.8722 },
        { "name": "Jaipur Junction", "code": "JP", "arrivalTime": "23 Jul, 6:30 PM", "latitude": 26.9196, "longitude": 75.7880 }
      ]
    }
  ]
}
"""

struct JourneyResponse: Codable {
    let journeys: [Journey]
}

func loadDummyJourneys() -> [Journey] {
    let data = Data(dummyJSON.utf8)
    do {
        let response = try JSONDecoder().decode(JourneyResponse.self, from: data)
        return response.journeys
    } catch {
        print("Error decoding dummy JSON: \(error)")
        return []
    }
}
