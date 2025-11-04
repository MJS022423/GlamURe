const Message = {
 Added_post: (user) => {return {message: `${user} has new post`}},
 Remove_post: (user) => {return {message: `${user} remove his post`}}, 
}

export default Message;