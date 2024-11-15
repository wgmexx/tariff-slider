import SwiftUI


struct Tariff: Identifiable {
    var id: String
    var speed: Int
}

struct CustomSteppedSlider: View {
    @State private var sliderValue: Double = 0.0
    @State private var tariffs: [Tariff] = []
    private let unit: String = "Мбит/с"
    
    var dotSizes: [CGFloat] {
        let minDotSize: CGFloat = 8
        let maxDotSize: CGFloat = 18
        let numTariffs = CGFloat(tariffs.count)
        
        if numTariffs < 2 {
            return Array(repeating: maxDotSize, count: Int(numTariffs))
        }
        
        return tariffs.enumerated().map { (index, _) in
            let scaleFactor = CGFloat(index) / (numTariffs - 1)
            let calculatedSize = minDotSize + (maxDotSize - minDotSize) * scaleFactor
            return calculatedSize
        }
    }
    
    func sendTariffSelectionToServer(selectedTariff: Tariff) {
        
        guard let url = URL(string: "????????") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let requestBody: [String: Any] = [
            "tariffId": selectedTariff.id,
            "speed": selectedTariff.speed
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
            
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending request: \(error.localizedDescription)")
                    return
                }
                
                
                if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    print("Tariff selected successfully")
                } else {
                    print("Failed to select tariff")
                }
            }.resume()
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                
                let sliderWidth = UIScreen.main.bounds.width - 32
                let sliderHeight: CGFloat = 24
                
                let maxDotSize = dotSizes.max() ?? 18
                let paddingHorizontal: CGFloat = maxDotSize / 5
                let dotPadding: CGFloat = maxDotSize * 1
                
                let innerSliderWidth = sliderWidth - 2 * paddingHorizontal
                let dotSliderWidth = innerSliderWidth - 2 * dotPadding
                
                let steps = (0..<tariffs.count).map { index in
                    CGFloat(index) / CGFloat(tariffs.count - 1)
                }
                
                ZStack {
                    ShapeWithArc()
                        .fill(Color.white)
                        .frame(width: innerSliderWidth, height: sliderHeight)
                        .cornerRadius(20)
                        .padding(.horizontal, paddingHorizontal)
                    
                    ShapeWithArc()
                        .fill(Color.red.opacity(0.25))
                        .frame(width: innerSliderWidth, height: sliderHeight)
                        .cornerRadius(20)
                        .padding(.horizontal, paddingHorizontal)
                        .mask(
                            HStack {
                                Rectangle()
                                    .frame(width: CGFloat(sliderValue) * innerSliderWidth + 8)
                                Spacer()
                            }
                        )
                    
                    ForEach(tariffs.indices, id: \.self) { index in
                        let dotSize = dotSizes[index]
                        let positionX = paddingHorizontal + dotPadding + steps[index] * dotSliderWidth
                        
                        Circle()
                            .fill(sliderValue == steps[index] ? Color.clear : Color("tssNotSelectedDot"))
                            .frame(width: dotSize, height: dotSize)
                            .position(x: positionX, y: sliderHeight * 1.15)
                            .opacity(sliderValue >= steps[index] ? 0.001 : 1)
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            sliderValue = steps[index]
                                            sendTariffSelectionToServer(selectedTariff: tariffs[index])
                                        }
                                    }
                            )
                            .zIndex(2)
                    }
                    
                    let currentStep = steps.min { abs($0 - sliderValue) < abs($1 - sliderValue) } ?? 0.0
                    let positionX = paddingHorizontal + dotPadding + currentStep * dotSliderWidth
                    
                    Circle()
                        .fill(.tssBackground)
                        .overlay(Circle().stroke(Color.red, lineWidth: 6))
                        .frame(width: 24)
                        .position(
                            x: positionX,
                            y: sliderHeight * 1.15
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragX = max(0, min(value.location.x - paddingHorizontal - dotPadding, dotSliderWidth))
                                    let newValue = dragX / dotSliderWidth
                                    let closestStep = steps.min { abs($0 - newValue) < abs($1 - newValue) }
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sliderValue = closestStep ?? 0.0
                                        if let index = steps.firstIndex(of: closestStep ?? 0.0) {
                                            sendTariffSelectionToServer(selectedTariff: tariffs[index])
                                        }
                                    }
                                }
                        )
                }
                
                ZStack {
                    ForEach(tariffs.indices, id: \.self) { index in
                        let speed = tariffs[index].speed
                        let isSelected = abs(sliderValue - steps[index]) < 0.1
                        let positionX = paddingHorizontal + dotPadding + steps[index] * dotSliderWidth
                        
                        VStack(spacing: 3) {
                            Text("\(speed)")
                                .font(.system(size: 12))
                                .fontWeight(isSelected ? .medium : .regular)
                                .foregroundColor(isSelected ? Color("tssSelectedText") : Color("tssText"))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sliderValue = steps[index]
                                        sendTariffSelectionToServer(selectedTariff: tariffs[index])                                    }
                                }
                            
                            Text(unit)
                                .font(.system(size: 9))
                                .fontWeight(isSelected ? .medium : .regular)
                                .foregroundColor(isSelected ? Color("tssSelectedText") : Color("tssText"))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sliderValue = steps[index]
                                        sendTariffSelectionToServer(selectedTariff: tariffs[index])
                                    }
                                }
                        }
                        .frame(width: 40)
                        .position(x: positionX, y: 25)
                    }
                }
                
            }
            .background(Color("tssBackground"))
            .cornerRadius(20)
            .padding(.horizontal, 16)
            .frame(height: 118)
            .onAppear {
                self.tariffs = [
                    Tariff(id: "1", speed: 100),
                    Tariff(id: "2", speed: 250),
                    Tariff(id: "3", speed: 500),
                    Tariff(id: "4", speed: 750),
                    Tariff(id: "5", speed: 1000),
                    Tariff(id: "6", speed: 2000)
                ]
            }
        }
    }
}

#Preview {
    
    CustomSteppedSlider()
    
}
