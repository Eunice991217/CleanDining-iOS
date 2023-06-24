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

    var currentLocation:CLLocationCoordinate2D!
    var findLocation:CLLocation!
    let geocoder = CLGeocoder()
    
    var longitude_HVC = 0.0
    var latitude_HVC = 0.0
    
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var addressText: UILabel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var addressView: UIView!
    
    @IBOutlet weak var searchBtn: UIView!
    
    @IBAction func didTapSearchBtn(_ sender: Any) {
        viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addressView.isHidden = false

        let mapView = NMFMapView(frame: view.frame)
        mapView.allowsZooming = true // 줌 가능
        mapView.allowsScrolling = true // 스크롤 가능
        // Naver 지도 마크 화면에서 제외
        mapView.contentInset = UIEdgeInsets(top: -50, left: -50, bottom: -50, right: -50)
       
        view.addSubview(mapView)
        view.addSubview(addressView)
        view.addSubview(searchBtn)
        
        searchBtn.layer.cornerRadius = 15
        searchBtn.layer.shadowOpacity = 1
        searchBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        searchBtn.layer.shadowOffset = CGSize(width: 0, height: -5)
        searchBtn.layer.shadowRadius = 20
        searchBtn.layer.masksToBounds = false
        searchBtn.clipsToBounds = false
        
        // addressView 모서리를 둥글게 설정
        addressView.layer.cornerRadius = 20
        
        // 위쪽만 그림자 지정
        addressView.layer.shadowOpacity = 1
        addressView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        addressView.layer.shadowOffset = CGSize(width: 0, height: -5)
        addressView.layer.shadowRadius = 20
        addressView.layer.masksToBounds = false
        addressView.clipsToBounds = false

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

        // 카메라 맞추기
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude), zoomTo: 14.0)
        mapView.moveCamera(cameraUpdate)
        cameraUpdate.animation = .easeIn
        
        self.addressText.numberOfLines = 0 // 줄 수를 0으로 설정하면 텍스트가 필요한 만큼 자동으로 줄 바꿈
        
        // 내 위치 마커
        let my_marker = NMFMarker()
        
        // 마커 위치
        my_marker.position = NMGLatLng(lat:latitude,lng: longitude)
        
        // 마커 이미지
        my_marker.iconImage = NMFOverlayImage(name: "me")

        // 마커 크기
        my_marker.width = 60
        my_marker.height = 60
        
        // 타입 이미지
        self.typeImage.image = UIImage(named: "me")
        
        // 이름 텍스트
        self.nameText.text = "현재 위치"

        // 마커 캡션
        my_marker.captionText = "내 위치"
        my_marker.captionOffset = 5
        my_marker.captionColor = UIColor.black

        my_marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            if self.addressView.isHidden {
                my_marker.width = 60
                my_marker.height = 60
                self.typeImage.image = UIImage(named: "me")

                self.nameText.text = "현재 위치"

                my_marker.captionText = "내 위치"
                my_marker.captionOffset = 5
                my_marker.captionColor = UIColor.black
                self.addressView.isHidden = false
                return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
            } else {
                my_marker.width = 50
                my_marker.height = 50
                 self.addressView.isHidden = true

                my_marker.captionText = ""
                return false // 이벤트 넘겨줌, -mapView:didTapMap:point 이벤트가 발생할 수 있음
            }
        }
        
        my_marker.mapView = mapView
        
        // API 통신 (localhost)
        guard let url = URL(string: "http://localhost:8080/main") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }

            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        
                        // dataModel에 받아온 정보 담기
                        let dataModel = try decoder.decode([DataModelElement].self, from: data)

                        // 비동기 처리
                        DispatchQueue.main.async {
                            for dataElement in dataModel {
                                // 마커 생성
                                let new_marker = NMFMarker()

                                // 마커 위치
                                new_marker.position = NMGLatLng(lat: dataElement.latitude, lng: dataElement.longitude)

                                // 업태 분류
                                if(dataElement.type == "한식") {
                                    new_marker.iconImage = NMFOverlayImage(name: "rice")
                                }
                                else if(dataElement.type == "분식") {
                                    new_marker.iconImage = NMFOverlayImage(name: "tteokbokki")
                                }
                                else if(dataElement.type == "커피숍") {
                                    new_marker.iconImage = NMFOverlayImage(name: "coffee")
                                }
                                else if(dataElement.type == "제과영업점") {
                                    new_marker.iconImage = NMFOverlayImage(name: "bread")
                                }
                                else if(dataElement.type == "경양식") {
                                    new_marker.iconImage = NMFOverlayImage(name: "tonkatsu")
                                }
                                else if(dataElement.type == "호프/통닭") {
                                    new_marker.iconImage = NMFOverlayImage(name: "chicken")
                                }
                                else if(dataElement.type == "패밀리 레스토랑") {
                                    new_marker.iconImage = NMFOverlayImage(name: "restaurant")
                                }
                                else if(dataElement.type == "중국식") {
                                    new_marker.iconImage = NMFOverlayImage(name: "jjajangmyeon")
                                }
                                else if(dataElement.type == "패스트푸드") {
                                    new_marker.iconImage = NMFOverlayImage(name: "hamburger")
                                }
                                else if(dataElement.type == "일식") {
                                    new_marker.iconImage = NMFOverlayImage(name: "sushi")
                                }

                                new_marker.width = 40
                                new_marker.height = 40

                                new_marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                                    if self.addressView.isHidden {
                                        if(dataElement.type == "한식") {
                                            self.typeImage.image = UIImage(named: "rice")
                                        }
                                        else if(dataElement.type == "분식") {
                                            self.typeImage.image = UIImage(named: "tteokbokki")
                                        }
                                        else if(dataElement.type == "커피숍") {
                                            self.typeImage.image = UIImage(named: "coffee")

                                        }
                                        else if(dataElement.type == "제과영업점") {
                                            self.typeImage.image = UIImage(named: "bread")

                                        }
                                        else if(dataElement.type == "경양식") {
                                            self.typeImage.image = UIImage(named: "tonkatsu")

                                        }
                                        else if(dataElement.type == "호프/통닭") {
                                            self.typeImage.image = UIImage(named: "chicken")

                                        }
                                        else if(dataElement.type == "패밀리 레스토랑") {
                                            self.typeImage.image = UIImage(named: "restaurant")

                                        }
                                        else if(dataElement.type == "중국식") {
                                            self.typeImage.image = UIImage(named: "jjajangmyeon")

                                        }
                                        else if(dataElement.type == "패스트푸드") {
                                            self.typeImage.image = UIImage(named: "hamburger")

                                        }
                                        else if(dataElement.type == "일식") {
                                            self.typeImage.image = UIImage(named: "sushi")

                                        }

                                        new_marker.width = 50
                                        new_marker.height = 50

                                        self.addressText.text = dataElement.address
                                        self.nameText.text = dataElement.name

                                        new_marker.captionText = dataElement.name
                                        new_marker.captionOffset = 5
                                        new_marker.captionColor = UIColor.black
                                        self.addressView.isHidden = false
                                        return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
                                    } else {
                                        if(dataElement.type == "한식") {
                                            self.typeImage.image = UIImage(named: "rice")
                                        }
                                        else if(dataElement.type == "분식") {
                                            self.typeImage.image = UIImage(named: "tteokbokki")
                                        }
                                        else if(dataElement.type == "커피숍") {
                                            self.typeImage.image = UIImage(named: "coffee")
                                        }
                                        else if(dataElement.type == "제과영업점") {
                                            self.typeImage.image = UIImage(named: "bread")
                                        }
                                        else if(dataElement.type == "경양식") {
                                            self.typeImage.image = UIImage(named: "tonkatsu")
                                        }
                                        else if(dataElement.type == "호프/통닭") {
                                            self.typeImage.image = UIImage(named: "chicken")
                                        }
                                        else if(dataElement.type == "패밀리 레스토랑") {
                                            self.typeImage.image = UIImage(named: "restaurant")
                                        }
                                        else if(dataElement.type == "중국식") {
                                            self.typeImage.image = UIImage(named: "jjajangmyeon")
                                        }
                                        else if(dataElement.type == "패스트푸드") {
                                            self.typeImage.image = UIImage(named: "hamburger")
                                        }
                                        else if(dataElement.type == "일식") {
                                            self.typeImage.image = UIImage(named: "sushi")
                                        }
                                        new_marker.width = 40
                                        new_marker.height = 40
                                        self.addressView.isHidden = true

                                        new_marker.captionText = ""
                                        return false // 이벤트 넘겨줌, -mapView:didTapMap:point 이벤트가 발생할 수 있음
                                    }
                                }

                                new_marker.mapView = mapView
                            }
                        }
                    } catch {
                        print("Error decoding data: \(error.localizedDescription)")
                    }
                } else {
                    print("No data received")
                }

            } else {
                print("HTTP status code: \(httpResponse.statusCode)")
            }
        }

        task.resume()

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
            getAddressByLocation()

            if(latitude_HVC == 0.0 || longitude_HVC == 0.0){
                print("위치를 가져올 수 없습니다.")
            }

    }
    
    // 위도, 경도 -> 도로명 주소로 바꾸기
    private func getAddressByLocation(){
        findLocation = CLLocation(latitude: latitude_HVC, longitude: longitude_HVC)
        if findLocation != nil {
            var address = ""
            geocoder.reverseGeocodeLocation(findLocation!) { (placemarks, error) in
                if error != nil {
                    return
                }
                if let placemark = placemarks?.first {
                    
                    if let locality = placemark.locality {
                        address = "\(address)\(locality) "
                    }
                    
                    if let thoroughfare = placemark.thoroughfare {
                        address = "\(address)\(thoroughfare) "
                    }
                    
                    if let subThoroughfare = placemark.subThoroughfare {
                         address = "\(address)\(subThoroughfare)"

                    }
                }
                self.addressText.text = address
                print(address)
            }
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
