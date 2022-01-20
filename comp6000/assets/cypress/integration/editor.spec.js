// editor.spec.js created with Cypress
//
// Start writing your Cypress tests below!
// If you're unfamiliar with how Cypress works,
// check out the link below and learn how to write your first test:
// https://on.cypress.io/writing-first-test

describe('Editor Test', () => {
    beforeEach(() => {
        cy.intercept('http://localhost:3000/run').as('runRequest')
        cy.visit('http://localhost:4000/app/editor')
    })
    
    it('run simple code', () => {
        cy.get('#ace-editor')
            .click()
            .type('console.log("hello");\nconsole.warn("warning");');
        
        cy.get('[data-cy=run]').click();
        
        cy.wait('@runRequest').then((interception) => {
            console.log(interception);
            expect(interception.response.body.logs).to.have.length(2);
            
            expect(interception.response.body.logs[0].type).to.equal("log");
            expect(interception.response.body.logs[0].data).to.have.length(1);
            expect(interception.response.body.logs[0].data[0]).to.equal("hello");

            expect(interception.response.body.logs[1].type).to.equal("warn");
            expect(interception.response.body.logs[1].data).to.have.length(1);
            expect(interception.response.body.logs[1].data[0]).to.equal("warning");
        })

        cy.get('[data-cy=console-line]').should('have.length', 2);

        cy.get('[data-cy=console-line]').then((logLines) => {            
            expect(logLines[0].children).to.have.length(2);

            expect(logLines[0].children[0].innerText).contains('log');
            expect(logLines[0].children[1].innerText).to.equal('hello');
            
            expect(logLines[1].children[0].innerText).contains('warn');
            expect(logLines[1].children[1].innerText).to.equal('warning');
        })
    })

    it('run code with an error', () => {
        cy.get('#ace-editor')
            .click()
            .type('foo()');

        cy.get('[data-cy=run]').click();

        cy.wait('@runRequest').then((interception) => {
            expect(interception.response.body.userCodeError).to.equal('foo is not defined');
        });

        cy.get('[data-cy=code-output]').contains('foo is not defined');
    })

    it('run code which will timeout', () => {
        cy.get('#ace-editor')
            .click()
            .type('while(true) { \nconsole.log("blah"); \n}');

        cy.get('[data-cy=run]').click();

        cy.wait('@runRequest').then((interception) => { 
            expect(interception.response.body.error).to.equal('timeout');
        });

        cy.get('[data-cy=code-output]').contains('Your code took too long to run');
    })
})