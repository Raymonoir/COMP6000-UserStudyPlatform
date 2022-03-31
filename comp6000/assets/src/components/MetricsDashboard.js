import Chart from 'react-c3-component';

class MetricsDashboard extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            studies: [],
            selectedStudyId: "",
            selectedStudy: null,
            selectedStudySurvey: null,
            metrics: {
                compile_map: {},
                replay_map: {}
            },
            chartFilter: {
                metric: "",
                question: ""
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
        this.chartFilterChange = this.chartFilterChange.bind(this);
    }

    changeSelectedStudy(e) {
        const selectedStudy = this.state.studies.filter(study => {
            return study.id == e.target.value;
        })[0]
        console.log("selected study: ", selectedStudy)
        this.setState({ selectedStudyId: e.target.value, selectedStudy: selectedStudy, chartData: null });

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

        let surveyReqs = []
        surveyReqs.push(backend.post('/api/survey/pre/get', {
            study_id: selectedStudy.id
        }));
        surveyReqs.push(backend.post('/api/survey/post/get', {
            study_id: selectedStudy.id
        }));
        Promise.all(surveyReqs).then(surveys => {
            this.setState({
                selectedStudySurvey: {
                    pre: surveys[0].survey_question.questions,
                    post: surveys[1].survey_question.questions
                }
            });

            const firstPreDropDown = surveys[0].survey_question.questions.find(question => {
                return JSON.parse(question).type == "dropdown";
            });
            const firsPosttDropDown = surveys[1].survey_question.questions.find(question => {
                return JSON.parse(question).type == "dropdown";
            });
            if (firstPreDropDown) {
                const index = surveys[0].survey_question.questions.indexOf(firstPreDropDown);
                this.chartFilterChange(JSON.stringify(['pre', index]));
            } else if (firsPosttDropDown) {
                const index = surveys[1].survey_question.questions.indexOf(firstPreDropDown);
                this.chartFilterChange(JSON.stringify(['post', index]));
            }
        });
    }

    chartFilterChange(question) {
        question = JSON.parse(question);
        console.log(question);
        this.setState({
            chartFilter: question
        });

        backend.post('/api/metrics/metrics-for-answers', {
            study_id: parseInt(this.state.selectedStudyId),
            preposition: question[0],
            question_pos: question[1],
            type: 'avg'
        }).then(metrics => {
            console.log("chart metrics: ", metrics);
            const columnNames = JSON.parse(this.state.selectedStudySurvey[question[0]][question[1]]).options;
            console.log('column names: ', columnNames);
            const groups = ['Idle Time', 'Inserted Characters', 'Line Count', 'Pasted Characters', 'Removed Characters', 'Total Time', 'Word Count', 'Words Per Minute'];
            let columns = []
            metrics.metrics.forEach((metric, i) => {
                console.log(metric);
                columns.push([
                    columnNames[i],
                    Math.round(metric.replay_map.idle_time * 10) / 10,
                    Math.round(metric.replay_map.insert_character_count * 10) / 10,
                    Math.round(metric.replay_map.line_count * 10) / 10,
                    Math.round(metric.replay_map.pasted_character_count * 10) / 10,
                    Math.round(metric.replay_map.remove_character_count * 10) / 10,
                    Math.round(metric.replay_map.total_time * 10) / 10,
                    Math.round(metric.replay_map.word_count * 10) / 10,
                    Math.round(metric.replay_map.words_per_minute * 10) / 10
                ]);
            });
            groups.unshift('x');
            columns.unshift(groups);
            console.log('columns: ', columns);
            this.setState({ chartData: columns });
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
                                                {this.state.metrics.compile_map.most_common_error[0] === '' &&
                                                    "The majority of participants had no errors"
                                                }
                                                {this.state.metrics.compile_map.most_common_error[0].length !== 0 &&
                                                    <span>"{this.state.metrics.compile_map.most_common_error[0]}" occured {this.state.metrics.compile_map.most_common_error[1]} times</span>
                                                }
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        }

                        {Object.keys(this.state.metrics.replay_map).length !== 0 &&
                            <div>
                                <h3>Sort Metrics By Survey Answers</h3>
                                <p>You can view how the metics differ based off how participants answered in the survey.</p>
                                <p>Choose the question you want to use to group the results.</p>
                                <p>Currently, the answers to dropdown questions can be used.</p>
                                <select
                                    value={this.state.chartFilter.question}
                                    onChange={(e) => {
                                        this.chartFilterChange(e.target.value);
                                    }}
                                >
                                    {this.state.selectedStudySurvey !== null &&
                                        this.state.selectedStudySurvey.pre.map((question, i) => {
                                            const parsedQuestion = JSON.parse(question);
                                            if (parsedQuestion.type == 'dropdown') {
                                                return <option value={JSON.stringify(['pre', i])} key={['pre', i]}>{parsedQuestion.question}</option>
                                            }
                                        })
                                    }
                                    {this.state.selectedStudySurvey !== null &&
                                        this.state.selectedStudySurvey.post.map((question, i) => {
                                            const parsedQuestion = JSON.parse(question);
                                            if (parsedQuestion.type == 'dropdown') {
                                                return <option value={JSON.stringify(['post', i])} key={['post', i]}>{parsedQuestion.question}</option>
                                            }
                                        })
                                    }
                                </select>
                                {this.state.chartData &&
                                    <Chart
                                        config={{
                                            data: {
                                                x: 'x',
                                                columns: this.state.chartData,
                                                type: 'bar'
                                            },
                                            axis: {
                                                x: {
                                                    type: 'category'
                                                }
                                            }
                                        }}
                                    />
                                }
                            </div>
                        }
                    </div>
                }
            </div>
        )
    }
}

export default MetricsDashboard