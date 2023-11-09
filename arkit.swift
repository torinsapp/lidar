import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    var session = ARSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        // Start the ARSession with a configuration that uses LiDAR
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics.insert(.sceneDepth)
        session.run(configuration)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    // Get the point cloud
    guard let pointCloud = frame.sceneDepth?.pointCloud else { return }
    let points = pointCloud.points
    
    // Print points to the console
    print(points.map { "\($0.x), \($0.y), \($0.z)" })
    
    // Serialize and send the points to the server (as shown above)
    sendDataToServer(points)
    }

    
    func sendDataToServer(_ points: [vector_float3]) {
    // Serialize points into a JSON array
    let pointsArray = points.map { [$0.x, $0.y, $0.z] }
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: pointsArray, options: [])
        
        // Create a URL for your server endpoint
        let url = URL(string: "http://192.168.1.203:8080")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending data: \(error)")
                return
            }
            // Check the response or handle the data
        }
        task.resume()
    } catch {
        print("Error serializing points: \(error)")
    }
    }

}
