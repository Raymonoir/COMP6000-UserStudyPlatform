import AceEditor from "react-ace-builds";

class Editor extends React.Component {
    constructor(props) {
        super(props);
        this.onChange = this.onChange.bind(this);
    }

    render() {
        return (
            <AceEditor
                mode="javascript"
                onChange={this.onChange}
            />
        );
    }

    onChange(value, delta) {
        console.log(value, delta);
    }
}

export default Editor;