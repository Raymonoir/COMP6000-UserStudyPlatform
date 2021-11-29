class Backend {
    get(uri) {
        return fetch(uri).then(res => { return res.json() });
    }

    post(uri, data) {
        return fetch(uri, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        }).then(res => {
            return res.json()
        });
    }
}
const backend = new Backend();
export default backend;