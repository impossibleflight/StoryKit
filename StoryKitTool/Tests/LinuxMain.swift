import XCTest

import GeneratorTests

var tests = [XCTestCaseEntry]()
tests += GeneratorTests.allTests()
XCTMain(tests)