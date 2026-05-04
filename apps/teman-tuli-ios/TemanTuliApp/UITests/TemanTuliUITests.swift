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
                transcript: "This transcript comes from simulator harness"
            )
        )

        XCTAssertTrue(app.staticTexts["live_caption_text"].waitForExistence(timeout: 5))

        let saveButton = app.buttons["save_private_button"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()
        XCTAssertTrue(app.staticTexts["save_success_message"].waitForExistence(timeout: 2))

        app.tabBars.buttons["Transcripts"].tap()

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()

        XCTAssertTrue(app.navigationBars["Transcript Detail"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["detail_transcript_text"].exists)

        app.navigationBars["Transcript Detail"].buttons.firstMatch.tap()

        let cellToDelete = app.cells.firstMatch
        XCTAssertTrue(cellToDelete.waitForExistence(timeout: 5))
        cellToDelete.swipeLeft()

        let deleteButtons = app.buttons.matching(identifier: "Delete")
        XCTAssertTrue(deleteButtons.firstMatch.waitForExistence(timeout: 2))
        deleteButtons.firstMatch.tap()
        if deleteButtons.firstMatch.waitForExistence(timeout: 1) {
            deleteButtons.firstMatch.tap()
        }

        XCTAssertTrue(app.staticTexts["No transcripts yet"].waitForExistence(timeout: 5))
    }

    func testInterruptionSimulationShowsFallbackMessage() {
        let app = launchApp(
            config: TemanTuliUITestLaunchConfig(
                authenticated: true,
                transcript: "Interruption transcript",
                interruption: .audio
            )
        )

        let startButton = app.buttons["start_caption_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        XCTAssertTrue(app.staticTexts["Recovery action: check permissions, backend connectivity, then try Start/Save again."].waitForExistence(timeout: 5))
    }
}
