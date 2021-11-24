// This is inserted into all JS files by esbuild
import React from 'react';
import {
    BrowserRouter,
    Switch,
    Route,
    Link
} from "react-router-dom";
import ReactDOM from 'react-dom';
import backend from "./helpers/backend.js";
export { React, BrowserRouter, Switch, Route, Link, ReactDOM, backend }