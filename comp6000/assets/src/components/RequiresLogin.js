import Login from './Login';

class RequiresLogin extends React.Component {
    constructor(props) {
        super(props);
        // If we have logged in previously then assume we are still logged in.
        // That allows the page to start loading faster while still checking
        // we are logged in eventually
        this.state = {
            loggedIn: window.sessionStorage.getItem('loggedIn') ?? false
        };

        backend.get('/api/users/loggedin').then(res => {
            this.setState({ loggedIn: res.loggedIn });
        }, error => {
            console.error(error);
        });

        this.onLogin = this.onLogin.bind(this);
    }

    render() {
        return (
            <div>
                {this.state.loggedIn ?
                    this.props.children :
                    <Login onLogin={this.onLogin} />}
            </div>
        );
    }

    onLogin() {
        window.sessionStorage.setItem('loggedIn', true);
        this.setState({ loggedIn: true });
    }
}

export default RequiresLogin;