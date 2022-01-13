class CodeRunner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            ran: false
        }
    }

    componentDidMount() {
        const abort = new AbortController();

        const request = fetch('http://localhost:3000/run', {
            signal: abort.signal,
            method: 'POST',
            mode: 'cors',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ code: this.props.code, run: this.props.run, args: this.props.args })
        })
            .then(res => res.json())
            .then(data => {
                console.log(data);
                this.setState({
                    ran: true,
                    result: data
                });
            });

        this.setState({
            request: request,
            abortController: abort
        });
    }

    componentWillUnmount() {
        this.state.abortController.abort();
    }

    render() {
        if (!this.state.ran) {
            return <div>Loading...</div>
        }

        return (
            <div>
                <div>
                    {
                        this.state.result.logs.map((line) => {
                            console.log(line.data);
                            return(
                                <p>
                                {line.data.map((dat) => {
                                    return <span>{dat + " "}</span>
                                    
                                    console.log(dat);
                                })}
                            </p>
                            )
                        })
                    }
                </div>
                <div>
                    {!this.state.result.error &&
                        <p>output: {this.state.result.output}</p>}

                    {this.state.result.error &&
                        <p>error: {this.state.result.error}</p>}
                </div>
            </div>
        );
    }
}

export default CodeRunner;