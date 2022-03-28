import App from './components/App';
import A from './components/A';
import B from './components/B';
import Login from './components/Login';
import Editor from './components/Editor';
import RequiresLogin from './components/RequiresLogin';
import StudyManager from './components/StudyManager';
import reportWebVitals from './reportWebVitals';
import StudyCreator from './components/StudyCreator';
import MetricsDashboard from './components/MetricsDashboard';

ReactDOM.render(
    <BrowserRouter basename="/app">
        <Route path="/">
            <Route exact path="/">
                <App />
            </Route>
            <Route path="/login">
                <Login />
            </Route>
            <Route path="/a">
                <RequiresLogin>
                    <A />
                </RequiresLogin>
            </Route>
            <Route path="/b">
                <B />
            </Route>
            <Route path="/editor">
                <Editor />
            </Route>
            <Route path="/createStudy">
                <RequiresLogin>
                    <StudyCreator />
                </RequiresLogin>
            </Route>
            <Route path="/study/:key" component={StudyManager} />
            <Route path="/studyMetrics">
                <RequiresLogin>
                    <MetricsDashboard />
                </RequiresLogin>
            </Route>
        </Route>
    </BrowserRouter >,
    document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
