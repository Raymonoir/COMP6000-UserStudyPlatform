class Popup extends React.Component {
    render() {
        return (
            <div>
                <div className="popup">
                    <div className="popup-content">
                        <p>{this.props.text}</p>
                        <div className="popup-buttons">
                            {
                                this.props.buttons.map((b, i) => {
                                    return <button className={"button " + b.style} onClick={b.action} key={i}>{b.text}</button>;
                                })
                            }
                        </div>
                    </div>
                </div>
                <div className="popup-background" onClick={() => { console.log('clicked background'); }}></div>
            </div>
        );
    }
}

export default Popup;