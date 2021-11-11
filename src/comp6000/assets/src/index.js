import App from './components/App';
import A from './components/A';
import B from './components/B';
import reportWebVitals from './reportWebVitals';


/* ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
); */
ReactDOM.render(
    <BrowserRouter basename="/app">
        <Route path="/">
            <Route exact path="/">
                <App />
            </Route>
            <Route path="/a">
                <A />
            </Route>
            <Route path="/b">
                <B />
            </Route>
        </Route>
    </BrowserRouter>,
    document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
