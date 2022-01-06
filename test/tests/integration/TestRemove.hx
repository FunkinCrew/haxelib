package tests.integration;

class TestRemove extends IntegrationTests {



	function testNormal():Void {
		final r = haxelib(["install", "libraries/libBar.zip"]).result();
		assertSuccess(r);

		final r = haxelib(["remove", "Bar"]).result();
		assertSuccess(r);

		final r = haxelib(["list", "Bar"]).result();
		assertSuccess(r);
		assertTrue(r.out.indexOf("Bar") < 0);
	}

	// for issue #529
	function testDifferentCapitalization() {
		final r = haxelib(["install", "libraries/libBar.zip"]).result();
		assertSuccess(r);

		final r = haxelib(["remove", "bar"]).result();
		assertSuccess(r);

		final r = haxelib(["list", "bar"]).result();
		assertSuccess(r);
		assertTrue(r.out.indexOf("Bar") < 0);
	}

	function testRemoveSpecificVersion() {
		final r = haxelib(["install", "libraries/libBar.zip"]).result();
		assertSuccess(r);

		final r = haxelib(["install", "libraries/libBar2.zip"]).result();
		assertSuccess(r);

		final r = haxelib(["list", "Bar"]).result();
		assertSuccess(r);
		assertTrue(r.out.indexOf("Bar") >= 0);
		assertTrue(r.out.indexOf("1.0.0") >= 0);
		assertTrue(r.out.indexOf("[2.0.0]") >= 0);

		// non current version can be removed
		final r = haxelib(["remove", "Bar", "1.0.0"]).result();
		assertSuccess(r);

		final r = haxelib(["list", "Bar"]).result();
		assertSuccess(r);
		assertTrue(r.out.indexOf("Bar") >= 0);
		assertTrue(r.out.indexOf("1.0.0") < 0);
		assertTrue(r.out.indexOf("[2.0.0]") >= 0);

		// current version cannot be removed
		final r = haxelib(["remove", "Bar", "2.0.0"]).result();
		assertFail(r);
		assertEquals(
			"Error: Cannot remove current version of library Bar",
			r.err.trim()
		);

		final r = haxelib(["list", "Bar"]).result();
		assertSuccess(r);
		assertTrue(r.out.indexOf("Bar") >= 0);
		assertTrue(r.out.indexOf("1.0.0") < 0);
		assertTrue(r.out.indexOf("[2.0.0]") >= 0);
	}
}
