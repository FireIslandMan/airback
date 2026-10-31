import AppKit
import ApplicationServices

// usage: axpop <bundleId> <AXRole> <index|list> [menuItemTitle]
// Lists AXPopUpButtons of the app's windows; with an index presses it and picks the menu item.
let args = CommandLine.arguments
let bundle = args[1]; let wantRole = args[2]
guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundle).first else { print("app not running"); exit(1) }
let ax = AXUIElementCreateApplication(app.processIdentifier)

func attr(_ e: AXUIElement, _ name: String) -> AnyObject? {
    var v: AnyObject?
    AXUIElementCopyAttributeValue(e, name as CFString, &v)
    return v
}
func children(_ e: AXUIElement) -> [AXUIElement] {
    return (attr(e, kAXChildrenAttribute) as? [AXUIElement]) ?? []
}
func role(_ e: AXUIElement) -> String { return (attr(e, kAXRoleAttribute) as? String) ?? "" }
func title(_ e: AXUIElement) -> String { return (attr(e, kAXTitleAttribute) as? String) ?? (attr(e, kAXValueAttribute) as? String) ?? "" }
func pos(_ e: AXUIElement) -> CGPoint {
    var p = CGPoint.zero
    if let v = attr(e, kAXPositionAttribute) { AXValueGetValue(v as! AXValue, .cgPoint, &p) }
    return p
}
func walk(_ e: AXUIElement, _ depth: Int, _ out: inout [AXUIElement], want: String) {
    if depth > 30 { return }
    if role(e) == want { out.append(e) }
    for c in children(e) { walk(c, depth + 1, &out, want: want) }
}

var pops: [AXUIElement] = []
for w in (attr(ax, kAXWindowsAttribute) as? [AXUIElement]) ?? [] { walk(w, 0, &pops, want: wantRole) }
if args.count < 4 || args[3] == "list" {
    for (i, p) in pops.enumerated() { print(i, title(p), pos(p)) }
    exit(0)
}
func pressAndPick(_ p: AXUIElement, _ want: String?) -> Bool {
    print("pressing", title(p), pos(p))
    AXUIElementPerformAction(p, kAXPressAction as CFString)
    usleep(900_000)
    var items: [AXUIElement] = []
    walk(p, 0, &items, want: "AXMenuItem")
    if items.isEmpty {
        for w in (attr(ax, kAXWindowsAttribute) as? [AXUIElement]) ?? [] { walk(w, 0, &items, want: "AXMenuItem") }
    }
    for it in items { print(" item:", title(it)) }
    guard let want = want else { return true }
    let exact = want.hasPrefix("="); let w = exact ? String(want.dropFirst()) : want
    if let hit = items.first(where: { exact ? title($0) == w : title($0).localizedCaseInsensitiveContains(w) }) {
        AXUIElementPerformAction(hit, kAXPressAction as CFString)
        print("picked", title(hit))
        return true
    }
    AXUIElementPerformAction(p, kAXCancelAction as CFString)
    // make sure the menu is closed
    let esc = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: true); esc?.post(tap: .cghidEventTap)
    let escU = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: false); escU?.post(tap: .cghidEventTap)
    usleep(400_000)
    print("item not found")
    return false
}
let want: String? = args.count > 4 ? args[4] : nil
if args[3] == "find" {
    for p in pops { if pressAndPick(p, want) { exit(0) } }
    print("no popup had it"); exit(1)
}
let idx = Int(args[3])!
_ = pressAndPick(pops[idx], want)
