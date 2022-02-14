class TaskList extends React.Component {
    constructor(props) {
        super(props)

        this.runAllTests = this.runAllTests.bind(this);
    }

    runAllTests(e, test = 0) {
        this.props.runTest(test, false, true)
            .then(() => {
                if (test < this.props.tasks.length - 1) {
                    this.runAllTests(e, test + 1);
                }
            })
    }

    render() {
        return (
            <div className="container primary">
                <h2>Tasks</h2>
                {
                    this.props.tasks.map((task, num) => {
                        return (
                            <div key={num} className={"task-list-item full-width " + (task.complete ? "completed" : "")}>
                                <span className="task-tick">✓</span>
                                <span className="task-description"><b>{num + 1}: </b>{task.content}</span>
                                <button className="button tertiary" onClick={() => { this.props.runTest(num, true); }} disabled={this.props.disableTesting}>Test</button>
                            </div>
                        );
                    })
                }
                <button className="button primary" onClick={this.runAllTests} disabled={this.props.disableTesting}>Run all tests</button>
            </div>
        );
    }
}

export default TaskList;