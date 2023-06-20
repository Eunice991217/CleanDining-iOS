//
//  ViewController.swift
//  CleanDining
//
//  Created by 김민경 on 2023/06/20.
//

import UIKit
import NMapsMap
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    let cameraPosition = NMFCameraPosition()

    var currentLocation:CLLocationCoordinate2D!
    var findLocation:CLLocation!
    let geocoder = CLGeocoder()
    
    var longitude_HVC = 0.0
    var latitude_HVC = 0.0
   
    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var addressView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = NMFMapView(frame: view.frame)
        mapView.allowsZooming = true // 줌 가능
        mapView.allowsScrolling = true // 스크롤 가능
        mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0) // 컨텐츠 패딩값 (하단 탭바만큼 패딩값)
        view.addSubview(mapView)
        view.addSubview(addressView)

        // addressView 모서리를 둥글게 설정
        addressView.layer.cornerRadius = 20
        addressView.layer.masksToBounds = true

        addressText.text = "서울특별시 강서구 등촌로13길 13, 1층 (화곡동)"
        addressText.numberOfLines = 0 // 줄 수를 0으로 설정하면 텍스트가 필요한 만큼 자동으로 줄 바꿈


        // delegate 설정
        locationManager.delegate = self
        // 사용자에게 허용 받기 alert 띄우기
        self.locationManager.requestWhenInUseAuthorization()
        requestAuthorization()

        // 내 위치 가져오기
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // 위도, 경도 가져오기
        let latitude = locationManager.location?.coordinate.latitude ?? 0
        let longitude = locationManager.location?.coordinate.longitude ?? 0

        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 15.0)
        mapView.moveCamera(cameraUpdate)
        cameraUpdate.animation = .easeIn

        // 마커
        let new_marker = NMFMarker()

        new_marker.position = NMGLatLng(lat:latitude,lng: longitude)
        new_marker.iconImage = NMFOverlayImage(name: "me")

        new_marker.width = 40
        new_marker.height = 40

        new_marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            if self.addressView.isHidden {
                new_marker.width = 50
                new_marker.height = 50
                self.addressView.isHidden = false
                return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
            } else {
                new_marker.width = 40
                new_marker.height = 40
                self.addressView.isHidden = true
                return false // 이벤트 넘겨줌, -mapView:didTapMap:point 이벤트가 발생할 수 있음
            }
        }

        new_marker.mapView = mapView

        print(latitude)
        print(longitude)

        // Do any additional setup after loading the view.
    }
    
    
    
    private func requestAuthorization() {

            //정확도 검사
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            //앱 사용할때 권한요청

            switch locationManager.authorizationStatus {
            case .restricted, .denied:
                print("restricted n denied")
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                print("권한있음")
                locationManagerDidChangeAuthorization(locationManager)
            default:
                locationManager.startUpdatingLocation()
                print("default")
            }

            locationManagerDidChangeAuthorization(locationManager)

            if(latitude_HVC == 0.0 || longitude_HVC == 0.0){
                print("위치를 가져올 수 없습니다.")
            }

    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            if let currentLocation = locationManager.location?.coordinate{
                print("coordinate")
                longitude_HVC = currentLocation.longitude
                latitude_HVC = currentLocation.latitude
            }
        }
        else{
            print("else")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude_HVC =  location.coordinate.latitude
            longitude_HVC = location.coordinate.longitude
        }
    }


}
