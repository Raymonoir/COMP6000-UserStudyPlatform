import Editor from '../components/Editor';

class AnswerSession extends React.Component {
    constructor(props) {
        super(props);

        this.uploadChunk = this.uploadChunk.bind(this);
    }

    render() {
        return (
            <Editor
                uploadChunk={this.uploadChunk}
                uploadFrequency={this.props.uploadFrequency}
            />
        );
    }

    uploadChunk(chunk) {
        // No need to send an empty chunk
        if (chunk.events.length) {
            console.log(chunk);
        }
    }
}

export default AnswerSession;