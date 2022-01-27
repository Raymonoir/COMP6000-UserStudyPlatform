import AceEditor from 'react-ace-builds';
import 'ace-builds/src-noconflict/mode-javascript';
import CodeRunner from './CodeRunner';

class Editor extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: '',
            history: [],
            startTime: +new Date(),
            lastUpdateTime: +new Date(),
            editor: null,
            lastRanCode: '',
            args: [],
            function: ''
        }

        this.runCode = this.runCode.bind(this);
        this.onChange = this.onChange.bind(this);
        this.replay = this.replay.bind(this);
        this.aceOnLoad = this.aceOnLoad.bind(this);
        this.getHistory = this.getHistory.bind(this);
    }

    componentDidMount() {
        if (this.props.uploadFrequency && this.props.uploadChunk) {
            this.setState({
                uploadInterval: setInterval(() => {
                    this.props.uploadChunk(this.getHistory());
                }, this.props.uploadFrequency)
            });
        }
    }

    componentWillUnmount() {
        if (this.state.uploadInterval) {
            clearInterval(this.state.uploadInterval);
        }
    }

    render() {
        return (
            <div>
                <div className="editor-container">
                    <AceEditor
                        mode="javascript"
                        className={"editor-on-page " + (window.matchMedia("(prefers-color-scheme: dark)").matches ? "ace-tomorrow-night ace_dark" : "ace-tomorrow")}
                        setOptions={{ useWorker: false }}
                        value={this.state.value}
                        onChange={this.onChange}
                        onLoad={this.aceOnLoad}
                    />
                </div>
            </div >
        );
        //<button className="button primary" onClick={this.runCode} data-cy="run">run</button>
        /* <CodeRunner
                        className="editor-code-output"
                        code={this.state.lastRanCode}
                        run={this.state.function}
                        args={this.state.args}
                    /> */
    }

    aceOnLoad(instance) {
        this.setState({ editor: instance });
    }

    onChange(value, delta) {
        const currTime = +new Date();
        const timeDiff = currTime - this.state.lastUpdateTime;
        let updatedHistory = [...this.state.history, [timeDiff, delta]];
        this.setState({
            value: value,
            history: updatedHistory,
            lastUpdateTime: currTime
        });

        // Send the current code back to our parent
        if (this.props.onCodeChange) {
            this.props.onCodeChange(value);
        }
    }

    getHistory(clear = true) {
        const output = {
            start: this.state.startTime,
            end: this.state.lastUpdateTime,
            events: this.state.history
        };

        if (clear) {
            this.setState({
                startTime: +new Date(),
                lastUpdateTime: +new Date(),
                history: []
            });
        }

        return output;
    }

    replay() {
        let history = this.state.history
        this.setState({ value: '', history: [] });

        this.state.editor.setReadOnly(true);

        const doNextStep = (step, lastStep) => {
            setTimeout(() => {
                if (step[1].action == 'insert') {
                    this.state.editor.moveCursorToPosition(step[1].start);
                    // Ace editor encodes a new line like this for some reason
                    if (step[1].lines.length == 2 && step[1].lines[1] == '' && step[1].lines[1] == '') {
                        this.state.editor.insert('\n');
                    } else {
                        if (step[1].lines.length > 1) {
                            let builtLine = '';
                            step[1].lines.forEach(line => {
                                builtLine += line + '\n';
                            });
                            this.state.editor.insert(builtLine);
                        } else {
                            this.state.editor.insert(step[1].lines.shift());
                        }
                    }
                } else if (step[1].action == 'remove') {
                    this.state.editor.moveCursorToPosition(step[1].start);
                    const r = new ace.Range(step[1].start.row, step[1].start.column, step[1].end.row, step[1].end.column);
                    this.state.editor.session.doc.remove(r);
                } else {
                    console.warn('Unknown action', step[1].action);
                }

                if (history.length) {
                    doNextStep(history.shift(), step);
                } else {
                    this.state.editor.setReadOnly(false);
                }
            }, step[0]);
        };

        doNextStep(history.shift());
    }

    runCode() {
        // Updating this will trigger the CodeRunner to run the code
        this.setState({ lastRanCode: this.state.value });
    }
}

export default Editor;