const execSync = require('child_process').execSync;
const fs = require('fs');

var myArgs = process.argv.slice(2)
if (myArgs.length != 1) {
    console.log("Expected argument: result bundle")
    return;
}

let testFile = myArgs[0]
if (!fs.existsSync(testFile)){
    console.log(`${testFile} must be a valid directory of a testbundle`)
    return;
}

function callXCResultTool(file, id = null, format = "json") {
    let opts = {maxBuffer: 1024 * 1024 * 100}
    let idParam = id ? ` --id ${id}` : ''
    let formatParam = ''

    if (format === "json") {
        opts.encoding = "utf8"
        formatParam = ` --format ${format}`
    }

    console.log(`Fetching ${format} for ${id}`)
    let output = execSync(`xcrun xcresulttool get --path "${file}" ${idParam} ${formatParam}`, opts);
    if (format === "json") {
        return JSON.parse(output)
    }
    return output;
}

// Parse main entry file
actionsInvocationRecord = callXCResultTool(testFile)
actionsInvocationRecord.actions._values.forEach(actionRecord => {
    let commandName = actionRecord.schemeCommandName._value
    let taskName = actionRecord.schemeTaskName._value
    let runDestination = actionRecord.runDestination.displayName._value
    console.log('actionRecord', commandName, taskName, runDestination)
    if (commandName === "Test" && (taskName === "Action" || taskName === 'BuildAndAction')) {
        console.log('> processing test action...')
        let testRefId = actionRecord.actionResult.testsRef.id._value
        if (testRefId) {
            // Get testplan execution summaries
            actionTestPlanRunSummaries = callXCResultTool(testFile, testRefId)
            actionTestPlanRunSummaries.summaries._values.forEach(testplanRunSummary => {
                let testPlanRunName = testplanRunSummary.name._value
                let recursion = 1
                console.log(" ",testPlanRunName)

                function actionTestSummaryGroup(test) {
                    console.log("   ".padEnd(recursion), 'test name',test.name._value)
                    if (test.summaryRef) {
                        let summaryRefId = test.summaryRef.id._value

                        // Parse main entry file
                        let actionTestSummary = callXCResultTool(testFile, summaryRefId)
                        let actionTestSummaryName = actionTestSummary.identifier._value
                        let status = actionTestSummary.testStatus._value
                        console.log(actionTestSummaryName,status)
                        actionTestSummary.activitySummaries._values.forEach((actionActivitySummary, index) => {
                            let title = actionActivitySummary.title._value
                            console.log("     ".padEnd(recursion), index, title)
                            if (actionActivitySummary.subactivities) {
                                actionActivitySummary.subactivities._values.forEach((subactivity)=>{
                                    if (subactivity.attachments) {
                                        subactivity.attachments._values.forEach((attachment)=>{
                                            let name = attachment.name._value
                                            let filename = attachment.filename._value
                                            let type = attachment.uniformTypeIdentifier._value
                                            console.log(name, filename, type)
                                            if (attachment.payloadRef) {
                                                let payloadRefId = attachment.payloadRef.id._value
                                                let data = callXCResultTool(testFile, payloadRefId, type)
                                                if (data) {
                                                    let dir = `${runDestination}/${testPlanRunName}/${actionTestSummaryName}`
                                                    if (!fs.existsSync(dir)){
                                                        console.log('Creating dir',dir)
                                                        fs.mkdirSync(dir, {recursive:true});
                                                    }
                                                    fs.writeFileSync(`${dir}/${filename}`, data, {flag:'w'})
                                                }
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                    if (test.subtests ) {
                        recursion++
                        test.subtests._values.forEach(actionTestSummaryGroup)
                        recursion--
                    }
                }

                testplanRunSummary.testableSummaries._values.forEach((testableSummary) => {
                    console.log("  ",testableSummary.name._value,testableSummary.testKind._value,testableSummary.testLanguage._value)
                    testableSummary.tests._values.forEach(actionTestSummaryGroup)
                })
            })
        }
    }
});

console.log("Done")
