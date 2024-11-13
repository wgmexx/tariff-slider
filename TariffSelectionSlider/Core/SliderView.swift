import SwiftUI


struct Tariff: Identifiable {
    var id: String
    var speed: Int
}

struct CustomSteppedSlider: View {
    @State private var sliderValue: Double = 0.08
    @State private var tariffs: [Tariff] = []
    private let unit: String = "Мбит/с"
    
    private let baseDotSizes: [CGFloat] = [8, 10, 12, 14, 16]
    
    var dotSizes: [CGFloat] {
        switch tariffs.count {
        case 2:
            return [8, 16]
        case 3:
            return [8, 12, 16]
        default:
            return Array(baseDotSizes.prefix(tariffs.count))
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            GeometryReader { geometry in
                let sliderWidth = geometry.size.width
                let numSteps = tariffs.count
                
                
                let stepSize = (0.93 - 0.08) / Double(numSteps - 1)
                
                
                let steps = (0..<numSteps).map { Double($0) * stepSize + 0.08 }

                ZStack(alignment: .leading) {
                    
                    let redLineWidth = sliderValue <= 0.08 ? 0 : CGFloat(sliderValue) * sliderWidth
                    let redLineHeight = 24 * sliderValue

                    
                    ShapeWithArc()
                        .fill(Color.red.opacity(0.25))
                        .frame(width: redLineWidth, height: redLineHeight)
                        .cornerRadius(12)
                        .position(x: redLineWidth / 2, y: geometry.size.height / 2)

                    
                    ShapeWithArc()
                        .fill(Color.white)
                        .frame(width: (sliderWidth - redLineWidth), height: 24)
                        .cornerRadius(12)
                        .offset(x: redLineWidth)

                    // Точки
                    ForEach(tariffs.indices, id: \.self) { index in
                        let dotSize = dotSizes[min(index, dotSizes.count - 1)]
                        let positionX = CGFloat(steps[index]) * sliderWidth
                        
                        Circle()
                            .fill(sliderValue == steps[index] ? Color.clear : Color("tssNotSelectedDot"))
                            .frame(width: dotSize, height: dotSize)
                            .position(x: positionX, y: geometry.size.height / 2)
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            sliderValue = steps[index]
                                        }
                                    }
                            )
                    }

                    Circle()
                        .fill(Color.white)
                        .overlay(Circle().stroke(Color.red, lineWidth: 6))
                        .frame(width: 24)
                        .position(
                            x: CGFloat(sliderValue) * sliderWidth,
                            y: geometry.size.height / 2
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let dragX = max(0, min(value.location.x, sliderWidth))
                                    let newValue = dragX / sliderWidth
                                    
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sliderValue = newValue
                                    }
                                }
                        )
                }
            }
            .frame(height: 30)
            .padding(.horizontal, 16)
             
            HStack {
                ForEach(tariffs.indices, id: \.self) { index in
                    let speed = tariffs[index].speed
                    
                    VStack(spacing: 2) {
                        Text("\(speed)")
                            .font(.system(size: 14))
                            .fontWeight(sliderValue == Double(index) / Double(tariffs.count - 1) ? .bold : .regular)
                            .foregroundColor(sliderValue == Double(index) / Double(tariffs.count - 1) ? Color("tssSelectedText") : Color("tssText"))
                        HStack {
                            Text(unit)
                                .font(.system(size: 12))
                                .fontWeight(sliderValue == Double(index) / Double(tariffs.count - 1) ? .bold : .regular)
                                .foregroundColor(sliderValue == Double(index) / Double(tariffs.count - 1) ? Color("tssSelectedText") : Color("tssText"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 4)
                }
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 20)
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
                Tariff(id: "5", speed: 1000)
            ]
        }
    }
}

#Preview {
    CustomSteppedSlider()
}
