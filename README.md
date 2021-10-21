# COMP6000-UserStudyPlatform

How to set up the project:
1. run `npm install` in `src/comp6000/assets`
2. run `mix deps.get` in `src/comp6000`
3. setup a postgresql server and enter the credentials in `src/comp6000/config/dev.exs`
4. run `mix ecto.create` in `src/comp6000`
5. start a development server by running `mix phx.server` in `src/comp6000`
