import AppKit

// AirBack video cards. usage:
//   cards <out.png> <mode> [args]
// modes:
//   bg                        starfield background 1920x1080 (opaque)
//   caption "EN||ES"          transparent 1920x1080 lower-third caption (EN white, ES amber-grey beneath)
//   title                     mark + wordmark + tagline (opaque)
//   line "EN||ES"             opaque starfield with one centered statement
//   steps                     iPhone step card: three steps with the mark
//   end                       end card: mark, Play line, GitHub line, DRM small print
//   thumb                     1280x720 thumbnail
// env: W, H override size (default 1920x1080)

let a = CommandLine.arguments
let out = a[1]; let mode = a[2]
let env = ProcessInfo.processInfo.environment
var W = Int(env["W"] ?? "1920")!; var H = Int(env["H"] ?? "1080")!
if mode == "thumb" { W = 1280; H = 720 }
let text = a.count > 3 ? a[3].replacingOccurrences(of: "\\n", with: "\n") : ""

let ground = NSColor(srgbRed: 0x05/255.0, green: 0x07/255.0, blue: 0x0D/255.0, alpha: 1)
let amber  = NSColor(srgbRed: 0xF5/255.0, green: 0x9E/255.0, blue: 0x0B/255.0, alpha: 1)
let white  = NSColor(srgbRed: 0.96, green: 0.96, blue: 0.97, alpha: 1)
let grey   = NSColor(srgbRed: 0.70, green: 0.72, blue: 0.78, alpha: 1)

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
let gctx = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = gctx
let ctx = gctx.cgContext
ctx.clear(CGRect(x: 0, y: 0, width: W, height: H))

func font(_ size: CGFloat, _ weight: NSFont.Weight = .semibold) -> NSFont {
    return NSFont.systemFont(ofSize: size, weight: weight)
}

// deterministic starfield, same recipe family as the app's Starfield.kt
func starfield() {
    ground.setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
    var seed: UInt64 = 0x9E3779B97F4A7C15
    func rnd() -> Double { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return Double((seed >> 11) & 0x1FFFFF) / Double(0x1FFFFF) }
    let n = (W * H) / 2600 as Int
    for _ in 0..<n {
        let x = rnd() * Double(W), y = rnd() * Double(H)
        let r = 0.6 + rnd() * rnd() * 1.9
        let al = 0.25 + rnd() * 0.65
        let warm = rnd() < 0.12
        (warm ? amber.withAlphaComponent(al * 0.8) : NSColor(white: 1, alpha: al)).setFill()
        NSBezierPath(ovalIn: NSRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r)).fill()
    }
    // soft vignette so captions read
    let g = NSGradient(colors: [NSColor(white: 0, alpha: 0), NSColor(white: 0, alpha: 0.55)])!
    g.draw(in: NSRect(x: 0, y: 0, width: Double(W), height: Double(H) * 0.42), angle: -90)
}

// the mark, drawn in a 108-unit box scaled to `s` pixels, origin bottom-left (x,y)
func mark(x: Double, y: Double, s: Double) {
    ctx.saveGState()
    ctx.translateBy(x: x, y: y)
    ctx.scaleBy(x: s / 108, y: s / 108)
    // flip to vector-drawable coords (y down)
    ctx.translateBy(x: 0, y: 108); ctx.scaleBy(x: 1, y: -1)
    ctx.setLineCap(.round); ctx.setLineJoin(.round); ctx.setLineWidth(5)
    func rr(_ r: CGRect, _ rad: CGFloat) -> CGPath { return CGPath(roundedRect: r, cornerWidth: rad, cornerHeight: rad, transform: nil) }
    // rear screen (open on the lower-left where the TV covers it): draw full rounded rect clipped
    ctx.saveGState()
    ctx.addRect(CGRect(x: 0, y: 0, width: 108, height: 108))
    ctx.addRect(CGRect(x: 22 - 2.5, y: 40 - 2.5, width: 50 + 5, height: 34 + 5))
    ctx.clip(using: .evenOdd)
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.addPath(rr(CGRect(x: 36, y: 24, width: 50, height: 34), 4)); ctx.strokePath()
    ctx.restoreGState()
    // front TV
    let tv = rr(CGRect(x: 22, y: 40, width: 50, height: 34), 4)
    ctx.setFillColor(ground.cgColor); ctx.addPath(tv); ctx.fillPath()
    ctx.setStrokeColor(NSColor.white.cgColor); ctx.addPath(tv); ctx.strokePath()
    // stand
    ctx.move(to: CGPoint(x: 47, y: 76)); ctx.addLine(to: CGPoint(x: 47, y: 82))
    ctx.move(to: CGPoint(x: 36, y: 84)); ctx.addLine(to: CGPoint(x: 58, y: 84)); ctx.strokePath()
    // return arrow
    ctx.setStrokeColor(amber.cgColor)
    ctx.move(to: CGPoint(x: 62, y: 51)); ctx.addLine(to: CGPoint(x: 44, y: 51))
    ctx.addArc(center: CGPoint(x: 44, y: 57), radius: 6, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
    ctx.addLine(to: CGPoint(x: 54, y: 63)); ctx.strokePath()
    ctx.setFillColor(amber.cgColor)
    ctx.move(to: CGPoint(x: 52, y: 57)); ctx.addLine(to: CGPoint(x: 61, y: 63)); ctx.addLine(to: CGPoint(x: 52, y: 69)); ctx.closePath(); ctx.fillPath()
    ctx.restoreGState()
}

func draw(_ s: String, size: CGFloat, weight: NSFont.Weight, color: NSColor, y: Double, maxW: Double, align: NSTextAlignment = .center, x: Double? = nil) -> Double {
    let p = NSMutableParagraphStyle(); p.alignment = align; p.lineSpacing = size * 0.18
    var f = size
    var attrs: [NSAttributedString.Key: Any] = [:]
    var h: CGFloat = 0
    for _ in 0..<20 {
        attrs = [.font: font(f, weight), .foregroundColor: color, .paragraphStyle: p]
        let r = (s as NSString).boundingRect(with: NSSize(width: maxW, height: 2000), options: [.usesLineFragmentOrigin], attributes: attrs)
        h = r.height
        let lines = Int((h / (f * 1.18)).rounded())
        if lines <= 2 || f <= 24 { break }
        f -= 2
    }
    let x0 = x ?? (Double(W) - maxW) / 2
    (s as NSString).draw(with: NSRect(x: x0, y: y, width: maxW, height: h + 10), options: [.usesLineFragmentOrigin], attributes: attrs)
    return Double(h)
}

func split(_ t: String) -> (String, String) {
    if let r = t.range(of: "||") { return (String(t[..<r.lowerBound]).trimmingCharacters(in: .whitespaces), String(t[r.upperBound...]).trimmingCharacters(in: .whitespaces)) }
    return (t, "")
}

switch mode {
case "bg":
    starfield()
case "caption":
    let (en, es) = split(text)
    // lower third plate
    let plateH = es.isEmpty ? 150.0 : 210.0
    let g = NSGradient(colors: [NSColor(white: 0, alpha: 0), ground.withAlphaComponent(0.85)])!
    g.draw(in: NSRect(x: 0, y: 0, width: Double(W), height: plateH + 120), angle: -90)
    var y = 64.0
    if !es.isEmpty { y += draw(es, size: 34, weight: .medium, color: grey, y: y, maxW: Double(W) * 0.8) + 14 }
    _ = draw(en, size: 46, weight: .semibold, color: white, y: y, maxW: Double(W) * 0.8)
case "line":
    starfield()
    let (en, es) = split(text)
    let esH = es.isEmpty ? 0 : 50.0
    let cy = Double(H) / 2
    if !es.isEmpty { _ = draw(es, size: 40, weight: .medium, color: grey, y: cy - 40 - esH, maxW: Double(W) * 0.72) }
    _ = draw(en, size: 60, weight: .bold, color: white, y: cy - 10, maxW: Double(W) * 0.72)
case "title":
    starfield()
    let s = 300.0
    mark(x: Double(W) / 2 - s / 2, y: Double(H) / 2 - 40, s: s)
    _ = draw("AirBack", size: 118, weight: .bold, color: white, y: Double(H) / 2 - 200, maxW: Double(W))
    _ = draw("AirPlay receiver for Google TV  ·  Receptor AirPlay para Google TV", size: 36, weight: .medium, color: grey, y: Double(H) / 2 - 262, maxW: Double(W))
case "steps":
    starfield()
    mark(x: 150, y: Double(H) / 2 - 150, s: 300)
    let rows: [(String, String, String)] = [
        ("1", "Open Control Center", "Abre el Centro de control"),
        ("2", "Tap Screen Mirroring", "Toca Duplicar pantalla"),
        ("3", "Choose your TV", "Elige tu TV")]
    var y = Double(H) / 2 + 190
    for (n, en, es) in rows {
        let bx = 560.0
        amber.setFill(); NSBezierPath(ovalIn: NSRect(x: bx, y: y - 84, width: 64, height: 64)).fill()
        _ = draw(n, size: 36, weight: .bold, color: ground, y: y - 76, maxW: 64, x: bx)
        _ = draw(en, size: 52, weight: .semibold, color: white, y: y - 78, maxW: 1100, align: .left, x: bx + 96)
        _ = draw(es, size: 30, weight: .medium, color: grey, y: y - 118, maxW: 1100, align: .left, x: bx + 96)
        y -= 170
    }
case "end":
    starfield()
    mark(x: Double(W) / 2 - 110, y: Double(H) - 420, s: 220)
    _ = draw("AirBack", size: 84, weight: .bold, color: white, y: Double(H) - 530, maxW: Double(W))
    _ = draw("Get it on Google Play  ·  Consíguelo en Google Play", size: 42, weight: .semibold, color: amber, y: Double(H) - 620, maxW: Double(W))
    _ = draw("Source: github.com/deJesusbiz/airback  ·  GPL-3.0", size: 32, weight: .medium, color: grey, y: Double(H) - 690, maxW: Double(W))
    let (en, es) = split(text)
    _ = draw(en, size: 28, weight: .regular, color: grey, y: 150, maxW: Double(W) * 0.8)
    if !es.isEmpty { _ = draw(es, size: 24, weight: .regular, color: grey.withAlphaComponent(0.8), y: 100, maxW: Double(W) * 0.8) }
case "thumb":
    starfield()
    mark(x: 80, y: 140, s: 440)
    _ = draw("AirPlay\nfor Google TV", size: 104, weight: .heavy, color: white, y: 310, maxW: 690, align: .left, x: 560)
    _ = draw("No ads. Gives your TV back.", size: 52, weight: .semibold, color: amber, y: 180, maxW: 720, align: .left, x: 560)
    _ = draw("$3.99 once  ·  open source", size: 38, weight: .medium, color: grey, y: 110, maxW: 720, align: .left, x: 560)
default:
    FileHandle.standardError.write("unknown mode\n".data(using: .utf8)!); exit(2)
}

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
