import AceEditor from 'react-ace-builds';
import 'ace-builds/src-noconflict/mode-javascript';

class Editor extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: '',
            history: [],
            startTime: +new Date(),
            lastUpdateTime: +new Date(),
            editor: null
        }

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
            <div ref="ace">
                <AceEditor
                    mode="javascript"
                    className={window.matchMedia("(prefers-color-scheme: dark)").matches ? "ace-tomorrow-night ace_dark" : "ace-tomorrow"}
                    setOptions={{ useWorker: false }}
                    value={this.state.value}
                    onChange={this.onChange}
                    onLoad={this.aceOnLoad}
                />
                <button onClick={this.replay}>replay</button>
                <button onClick={this.getHistory}>get history</button>
            </div >
        );
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
}

export default Editor;