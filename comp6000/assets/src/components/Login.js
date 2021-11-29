class Login extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            username: '',
            password: '',
            loading: false,
            incorrect: false,
            goToHomepage: false
        }

        this.handleChange = this.handleChange.bind(this);
        this.login = this.login.bind(this);

        // If it looks like we are logged in and our parent isn't handling
        // what should happen after login then check to make sure we aren't
        // already logged in
        if (window.sessionStorage.getItem('loggedIn') && !props.onLogin) {
            backend.get('/api/users/loggedin').then(res => {
                if (res.loggedIn) {
                    window.sessionStorage.setItem('loggedIn', true);
                    this.setState({ goToHomepage: true });
                }
            });
        }
    }

    render() {
        return (
            <div className="container-centered">
                <h1>Login</h1>
                {this.state.incorrect && <p>Incorrect username or password</p>}
                <form onSubmit={this.login}>
                    <label>
                        <p>Username/email</p>
                        <input
                            type="text"
                            name="username"
                            value={this.state.username}
                            disabled={this.state.loading ? true : false}
                            onChange={this.handleChange} />
                    </label>
                    <label>
                        <p>Password</p>
                        <input
                            type="password"
                            name="password"
                            value={this.state.password}
                            disabled={this.state.loading ? true : false}
                            onChange={this.handleChange} />
                    </label>
                    <div>
                        <button type="submit" disabled={this.state.loading ? true : false}>
                            Login
                        </button>
                    </div>
                </form>
                {this.state.goToHomepage && <Redirect to="/" />}
            </div>
        );
    }

    handleChange(e) {
        this.setState({
            [e.target.name]: e.target.value
        });
    }

    login(e) {
        e.preventDefault();
        this.setState({ loading: true });

        backend.post('/api/users/login', {
            username: this.state.username,
            password: this.state.password
        }).then(res => {
            if (res.login) {
                if (this.props.onLogin) {
                    this.props.onLogin();
                } else {
                    window.sessionStorage.setItem('loggedIn', true);
                    this.setState({ goToHomepage: true });
                }

            } else {
                this.setState({ incorrect: true });
                this.setState({ loading: false });
            }
        }, error => {
            console.error(error);
            this.setState({ loading: false });
        });
    }
}

export default Login;