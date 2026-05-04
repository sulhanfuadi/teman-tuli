import XCTest

final class TemanTuliUITests: XCTestCase {
    private func launchApp(config: TemanTuliUITestLaunchConfig) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += config.launchArguments()
        app.launch()
        return app
    }

    func testHappyPathSaveArchiveDetailAndDeleteFlow() {
        let app = launchApp(
            config: TemanTuliUITestLaunchConfig(
                authenticated: true,
                transcript: "Ini transkrip dari harness simulator"
            )
        )

        XCTAssertTrue(app.staticTexts["live_caption_text"].waitForExistence(timeout: 5))

        let saveButton = app.buttons["save_private_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()
        XCTAssertTrue(app.staticTexts["save_success_message"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Transkrip"].tap()
        XCTAssertTrue(app.tables["sessions_list"].waitForExistence(timeout: 5))

        let firstCell = app.tables["sessions_list"].cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()

        XCTAssertTrue(app.navigationBars["Detail Transkrip"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["detail_transcript_text"].exists)

        app.navigationBars["Detail Transkrip"].buttons.firstMatch.tap()
        XCTAssertTrue(app.tables["sessions_list"].waitForExistence(timeout: 5))

        let cellToDelete = app.tables["sessions_list"].cells.firstMatch
        XCTAssertTrue(cellToDelete.exists)
        cellToDelete.swipeLeft()
        app.buttons["Hapus"].tap()
        app.buttons["Hapus"].tap()

        XCTAssertTrue(app.staticTexts["Belum ada transkrip"].waitForExistence(timeout: 5))
    }

    func testInterruptionSimulationShowsFallbackCard() {
        let app = launchApp(
            config: TemanTuliUITestLaunchConfig(
                authenticated: true,
                transcript: "Transkrip interruption",
                interruption: .audio
            )
        )

        let startButton = app.buttons["start_caption_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        XCTAssertTrue(app.otherElements["fallback_card"].waitForExistence(timeout: 5))
    }
}
