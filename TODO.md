# TODO: Connect Comment Folder to PostFeed.jsx

- [x] Fix backend/src/modules/Comment/Comment.Display.js to query and return comments for a specific post (add Postid query param)
- [x] Fix backend/src/modules/Comment/Comment.Remove.js to remove a comment (add postid, commentid params)
- [x] Update frontend/src/dash-component/homepage-modules/PostFeed.jsx to fetch comments on modal open, send add comment to backend, update local state after success
- [x] Test the integration by running backend and frontend, verifying comments add/display in PostFeed modal
