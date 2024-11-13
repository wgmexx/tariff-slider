import SwiftUI

struct CustomFrame: View {
    var body: some View {
        ZStack {
            ShapeWithArc()
                .frame(height: 24)
        }
    }
}

#Preview {
    CustomFrame()
}

struct ShapeWithArc: Shape {
    func path(in rect: CGRect) -> Path {
        let leftSideHeight = rect.height / 2
        let leftCornerRadius: CGFloat = min(12, leftSideHeight / 2)
        let rightCornerRadius: CGFloat = 12
        
        return Path { path in
            let topLeft = CGPoint(x: rect.minX, y: rect.midY - leftSideHeight / 2)
            let bottomLeft = CGPoint(x: rect.minX, y: rect.midY + leftSideHeight / 2)
            
            let topRight = CGPoint(x: rect.maxX, y: rect.minY)
            let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
            
            path.move(to: CGPoint(x: topLeft.x + leftCornerRadius, y: topLeft.y))
            
            path.addLine(to: CGPoint(x: topRight.x - rightCornerRadius, y: topRight.y))
            path.addQuadCurve(to: CGPoint(x: topRight.x, y: topRight.y + rightCornerRadius),
                              control: CGPoint(x: topRight.x, y: topRight.y))
            
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - rightCornerRadius))
            path.addQuadCurve(to: CGPoint(x: bottomRight.x - rightCornerRadius, y: bottomRight.y),
                              control: CGPoint(x: bottomRight.x, y: bottomRight.y))
            
            path.addLine(to: CGPoint(x: bottomLeft.x + leftCornerRadius, y: bottomLeft.y))
            path.addQuadCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - leftCornerRadius),
                              control: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
            
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + leftCornerRadius))
            path.addQuadCurve(to: CGPoint(x: topLeft.x + leftCornerRadius, y: topLeft.y),
                              control: CGPoint(x: topLeft.x, y: topLeft.y))
        }
    }
}
