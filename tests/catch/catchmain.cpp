#define CATCH_CONFIG_MAIN

#include "../../src/gba.h"
#include "catch.hpp"

/*
// setup and teardown for tests. see for more info:
// https://github.com/catchorg/Catch2/blob/master/docs/event-listeners.md
struct SetupTeardownListener : Catch::TestEventListenerBase {

    using TestEventListenerBase::TestEventListenerBase; // inherit constructor

    void testCaseStarting(Catch::TestCaseInfo const& testInfo) override {
        gba_init();
    }
    
    void testCaseEnded(Catch::TestCaseStats const& testCaseStats) override {
        cleanup_memory();
    }
};
CATCH_REGISTER_LISTENER(SetupTeardownListener)*/