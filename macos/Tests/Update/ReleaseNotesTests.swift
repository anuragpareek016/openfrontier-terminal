import Testing
@testable import OpenFrontier

struct ReleaseNotesTests {
    @Test func localBuildHasNoRemoteReleaseNotes() {
        let tagged = UpdateState.ReleaseNotes(
            displayVersionString: "1.3.1",
            currentCommit: "332b2aefc"
        )
        let tip = UpdateState.ReleaseNotes(
            displayVersionString: "tip-abc1234",
            currentCommit: "332b2aefc"
        )

        #expect(tagged == nil)
        #expect(tip == nil)
    }
}
