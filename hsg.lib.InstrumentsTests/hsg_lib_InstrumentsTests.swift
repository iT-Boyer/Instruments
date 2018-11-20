//
//  hsg_lib_InstrumentsTests.swift
//  hsg.lib.InstrumentsTests
//
//  Created by admin on 2018/11/13.
//  Copyright © 2018年 clcw. All rights reserved.
//

import XCTest
@testable import hsg_lib_Instruments
import hsg_lib_Utils

class hsg_lib_InstrumentsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //激活虚拟网络
        InstallHTTPStubs.activateHttpStub()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
