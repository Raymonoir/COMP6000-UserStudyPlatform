import AceEditor from "react-ace-builds";

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
        this.selectionHandler = this.selectionHandler.bind(this);
    }

    render() {
        return (
            <div ref="ace"
                onMouseDown={this.selectionHandler}
                onMouseUp={this.selectionHandler}
                onMouseMove={this.selectionHandler}>
                <AceEditor
                    mode="javascript"
                    value={this.state.value}
                    onChange={this.onChange}
                    onLoad={this.aceOnLoad}
                />
                <button onClick={this.replay}>replay</button>
            </div>
        );
    }

    aceOnLoad(instance) {
        this.setState({ editor: instance });
        console.log(instance);
    }

    selectionHandler(event) {
        //console.log(event);
        switch (event.type) {
            case 'mousedown':
                console.log('mouse down');
                break;
            case 'mouseup':
                console.log('mouse up');
                break;
            case 'mousemove':
                console.log('mouse move');
                break
        }
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
        console.log(this.state.history);
    }

    replay() {
        let history = this.state.history
        this.setState({ value: '', history: [] });

        this.state.editor.setReadOnly(true);

        const doNextStep = (step, lastStep) => {
            setTimeout(() => {
                // If we selected something before we must unselect it
                if (lastStep && lastStep[1].action == 'select' && step[1].action != 'select') {
                    const r = new ace.Range(lastStep[1].start.row, lastStep[1].start.column, lastStep[1].end.row, lastStep[1].end.column);
                    this.state.editor.removeSelectionMarker(r);
                }

                if (step[1].action == 'insert') {
                    this.state.editor.moveCursorToPosition(step[1].start);
                    // Ace editor encodes a new line like this for some reason
                    if (step[1].lines.length == 2 && step[1].lines[1] == '' && step[1].lines[1] == '') {
                        this.state.editor.insert('\n');
                    } else {
                        if (step[1].lines.length > 1) {
                            step[1].lines.forEach(line => {
                                this.state.editor.insert(line + '\n');
                            });
                        } else {
                            this.state.editor.insert(step[1].lines.shift());
                        }
                    }
                } else if (step[1].action == 'remove') {
                    this.state.editor.moveCursorToPosition(step[1].start);
                    const r = new ace.Range(step[1].start.row, step[1].start.column, step[1].end.row, step[1].end.column);
                    this.state.editor.session.doc.remove(r);
                } else if (step[1].action == 'select') {
                    const r = new ace.Range(step[1].start.row, step[1].start.column, step[1].end.row, step[1].end.column);
                    this.state.editor.addSelectionMarker(r);
                } else if (step[1].action == 'click') {
                    this.state.editor.moveCursorToPosition(step[1].start);
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