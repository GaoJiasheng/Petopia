import XCTest

final class RunnerUITests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  func testSetLandscapeOrientation() {
    XCUIDevice.shared.orientation = .landscapeLeft
    XCTAssertEqual(XCUIDevice.shared.orientation, .landscapeLeft)
  }

  func testHoldLandscapeOrientationForVisualAudit() {
    XCUIDevice.shared.orientation = .landscapeLeft
    XCTAssertEqual(XCUIDevice.shared.orientation, .landscapeLeft)
    Thread.sleep(forTimeInterval: 240)
  }

  func testSetPortraitOrientation() {
    XCUIDevice.shared.orientation = .portrait
    XCTAssertEqual(XCUIDevice.shared.orientation, .portrait)
  }
}
