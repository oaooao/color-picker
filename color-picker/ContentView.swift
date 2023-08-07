import SwiftUI
import AppKit

struct ContentView: View {
    
    @State private var selectedColor: NSColor = .clear
    @State private var colorHistory: [NSColor] = []
    @State private var selectedFormat: ColorFormat = .hexCode
    
    @State private var settings: Settings = Settings()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
//                Text("Color Picker")
//                    .font(.largeTitle)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(selectedColor)))
                    .frame(width: 100, height: 100)
                    .shadow(radius: 10)
                
                Button(action: {
                    let sampler = NSColorSampler()
                    sampler.show { color in
                        if let color = color {
                            self.selectedColor = color
                            self.colorHistory.insert(color, at: 0)
                            if self.colorHistory.count > 20 {
                                self.colorHistory.removeLast()
                            }
                            
                            if self.settings.copyToClipboard {
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.setString(self.selectedColorCode, forType: .string)
                            }
                        }
                    }
                }) {
                    Text("Pick Color")
                            .fontWeight(.medium)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 25)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                            .frame(width: 180, height: 50)  // Explicitly setting the frame size
                            )
                            .buttonStyle(PlainButtonStyle())  // Removing the default macOS button style
                            .foregroundColor(Color.blue.opacity(0.8))
                }
                
                if selectedColor != .clear {
                    Text(selectedColorCode)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(colorHistory, id: \.self) { color in
                                            ZStack(alignment: .topTrailing) {
                                                VStack {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color(color))
                                                        .frame(width: 50, height: 50)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                                        )
                                                        .onTapGesture {
                                                            // Update panel color and copy color value to clipboard
                                                            self.selectedColor = color
                                                            let pasteboard = NSPasteboard.general
                                                            pasteboard.clearContents()
                                                            pasteboard.setString(color.hexCode, forType: .string)
                                                        }
                                                    Text(color.hexCode)
                                                        .font(.caption2)
                                                        .foregroundColor(.white)
                                                        .padding(.top, 5)
                                                }
                                                Button(action: {
                                                    if let index = colorHistory.firstIndex(of: color) {
                                                        colorHistory.remove(at: index)
                                                    }
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(Color.white.opacity(0.8))
                                                        .font(.system(size: 14))
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .padding([.top, .trailing], 4)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .padding(.top, 20)
                
                GroupBox(label: Text("Settings").foregroundColor(.white)) {
                    Toggle(isOn: $settings.copyToClipboard) {
                        Text("Copy to clipboard on pick")
                            .foregroundColor(.white)
                    }
                    .padding(.top)

                    Toggle(isOn: $settings.hexUppercase) {
                        Text("HEX in uppercase")
                            .foregroundColor(.white)
                    }
                    .padding(.top)

                    Picker("Color Format", selection: $settings.colorFormat) {
                        ForEach(ColorFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top)
                }
                .padding()
                .background(Color.white.opacity(0.15))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .padding(.top, 30)
            }
            .padding(.horizontal, 40)
        }
    }
    
    var selectedColorCode: String {
        switch settings.colorFormat {
        case .hexCode:
            return settings.hexUppercase ? selectedColor.hexCode.uppercased() : selectedColor.hexCode.lowercased()
        case .rgba:
            return "RGBA(\(Int((selectedColor.rgb?.red ?? 0) * 255)), \(Int((selectedColor.rgb?.green ?? 0) * 255)), \(Int((selectedColor.rgb?.blue ?? 0) * 255)), \(Int(selectedColor.alphaComponent * 255)))"
        }
    }
}

enum ColorFormat: String, CaseIterable {
    case hexCode = "HEX"
    case rgba = "RGBA"
}

extension NSColor {
    var rgbColor: NSColor? {
        return usingColorSpace(.deviceRGB)
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        guard let rgbColor = rgbColor else { return nil }
        return (red: rgbColor.redComponent, green: rgbColor.greenComponent, blue: rgbColor.blueComponent)
    }
    
    var hexCode: String {
        let red = Int((rgbColor?.redComponent ?? 0) * 255.0)
        let green = Int((rgbColor?.greenComponent ?? 0) * 255.0)
        let blue = Int((rgbColor?.blueComponent ?? 0) * 255.0)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}

struct Settings {
    var copyToClipboard: Bool = true
    var colorFormat: ColorFormat = .hexCode
    var hexUppercase: Bool = true
}

