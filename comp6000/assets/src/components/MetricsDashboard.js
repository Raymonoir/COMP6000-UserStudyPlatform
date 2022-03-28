import backend from "../helpers/backend";

class MetricsDashboard extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            studies: [],
            selectedStudyId: "",
            selectedStudy: null,
            metrics: {
                compile_map: {},
                replay_map: {}
            }
        }

        backend.get('/api/users/get').then(userData => {
            console.log(userData);
            this.setState({ username: userData.user })
            backend.post('/api/study/get', {
                username: userData.user
            }).then(studies => {
                this.setState({ studies: studies.study })
                this.changeSelectedStudy({
                    target: {
                        value: studies.study[0].id
                    }
                })
            });
        });

        this.changeSelectedStudy = this.changeSelectedStudy.bind(this);
    }

    changeSelectedStudy(e) {
        const selectedStudy = this.state.studies.filter(study => {
            return study.id == e.target.value;
        })[0]
        console.log("selected study: ", selectedStudy)
        this.setState({ selectedStudyId: e.target.value, selectedStudy: selectedStudy });

        backend.post('/api/metrics/current', {
            study_id: selectedStudy.id
        }).then(metrics => {
            console.log("got metrics: ", metrics);
            let filteredMetrics = metrics.metrics;
            Object.keys(filteredMetrics.replay_map).forEach(metric => {
                filteredMetrics.replay_map[metric] = Math.round(filteredMetrics.replay_map[metric] * 10) / 10
            });
            Object.keys(filteredMetrics.compile_map).forEach(metric => {
                if (typeof filteredMetrics.compile_map[metric] == 'number') {
                    filteredMetrics.compile_map[metric] = Math.round(filteredMetrics.compile_map[metric] * 10) / 10
                }
            });
            this.setState({ metrics: filteredMetrics });
        });
    }

    render() {
        return (
            <div className="container primary centered">
                <h2>My studies</h2>
                <p>Pick a study to view the collected metrics</p>
                <select value={this.state.selectedStudyId} onChange={this.changeSelectedStudy}>
                    {
                        this.state.studies.map((study) => {
                            return <option key={study.id} value={study.id}>{study.title}</option>
                        })
                    }
                </select>
                <hr />
                {this.state.selectedStudyId &&
                    <div>
                        <h2>Viewing metrics for "{this.state.selectedStudy.title}"</h2>
                        {Object.keys(this.state.metrics.replay_map).length === 0 &&
                            <p>Looks like no one has participated in this study yet</p>
                        }

                        {Object.keys(this.state.metrics.replay_map).length !== 0 &&
                            <div>
                                <h3>Typing/Replay Metrics</h3>
                                <p>Metrics showing the average values of different statistics recorded from every participant's attempt at the study</p>
                                <table className="metrics-table">
                                    <thead>
                                        <tr>
                                            <th>Metric</th>
                                            <th>Average Value</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Idle Time</td>
                                            <td>{this.state.metrics.replay_map.idle_time}</td>
                                        </tr>
                                        <tr>
                                            <td>Total Inserted Characters</td>
                                            <td>{this.state.metrics.replay_map.insert_character_count}</td>
                                        </tr>
                                        <tr>
                                            <td>Total line count</td>
                                            <td>{this.state.metrics.replay_map.line_count}</td>
                                        </tr>
                                        <tr>
                                            <td>Pasted Characters Count</td>
                                            <td>{this.state.metrics.replay_map.pasted_character_count}</td>
                                        </tr>
                                        <tr>
                                            <td>Removed Characters Count</td>
                                            <td>{this.state.metrics.replay_map.remove_character_count}</td>
                                        </tr>
                                        <tr>
                                            <td>Time Spent</td>
                                            <td>{this.state.metrics.replay_map.total_time}</td>
                                        </tr>
                                        <tr>
                                            <td>Word Count</td>
                                            <td>{this.state.metrics.replay_map.word_count}</td>
                                        </tr>
                                        <tr>
                                            <td>Words Per Minute</td>
                                            <td>{this.state.metrics.replay_map.words_per_minute}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        }

                        {Object.keys(this.state.metrics.compile_map).length !== 0 &&
                            <div>
                                <h3>Code Execution Metrics</h3>
                                <p>Metrics recorded from every time a participant ran their code</p>
                                <table className="metrics-table">
                                    <thead>
                                        <tr>
                                            <th>Metric</th>
                                            <th>Average/Most common value</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Times Executed</td>
                                            <td>{this.state.metrics.compile_map.times_compiled}</td>
                                        </tr>
                                        <tr>
                                            <td>Most Common Error</td>
                                            <td>
                                                {this.state.metrics.compile_map.most_common_error.length === 0 &&
                                                    "No participants have had any errors"
                                                }
                                                {this.state.metrics.compile_map.most_common_error}
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        }
                    </div>
                }
            </div>
        )
    }
}

export default MetricsDashboard