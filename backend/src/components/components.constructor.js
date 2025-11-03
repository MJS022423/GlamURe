async function userSchema(req) {
  const { username, email, password } = req.body;
  return { Username: `${username}`, Email: `${email}`, Password: `${password}`, Bookmark: null, notification: null, Post: null};
};
