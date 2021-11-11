import A from './A';
import B from './B';

class App extends React.Component {
    render() {
        return (
            <div>
                <p>This is the app</p>
                <div>
                    <Link to="/a">To A</Link>
                </div>
                <div>
                    <Link to="/b">To B</Link>
                </div>
            </div>
        );
    }
}

export default App;
