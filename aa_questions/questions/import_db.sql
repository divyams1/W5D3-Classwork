PRAGMA foreign_keys = ON;

DROP TABLE question_likes;
DROP TABLE replies;
DROP TABLE question_follows;
DROP TABLE questions; 
DROP TABLE users;

CREATE TABLE users(
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);



CREATE TABLE questions(
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT,
    user_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id)
);


CREATE TABLE question_follows(
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY(question_id) REFERENCES questions(id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);



CREATE TABLE replies(
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    question_id INTEGER NOT NULL,   
    parent_reply_id  INTEGER, 
    user_id  INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
    
);

CREATE TABLE question_likes(
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO 
  users (fname, lname)
VALUES 
  ('James', 'Bond'),
  ('Luke', 'Skywalker'); 

INSERT INTO 
  questions (title, body, user_id)
VALUES 
  ('Cooking Pancakes','How to make pancakes?', (SELECT id FROM users WHERE fname = "James" AND lname = "Bond")),
  ('Lightsabers','How do I clean my lightsaber?', (SELECT id FROM users WHERE fname = "Luke" AND lname = "Skywalker")),
  ('Lightsabers2','How do I clean my lightsaber2?', (SELECT id FROM users WHERE fname = "Luke" AND lname = "Skywalker"));

INSERT INTO 
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = "Lightsabers"),
  (SELECT id FROM users WHERE fname = 'Luke' AND lname = 'Skywalker')),
  
  ((SELECT id FROM questions WHERE title = "Lightsabers"),
  (SELECT id FROM users WHERE fname = 'James' AND lname = 'Bond')),

  
  ((SELECT id FROM questions WHERE title = "Cooking Pancakes"),
  (SELECT id FROM users WHERE fname = 'James' AND lname = 'Bond'));

INSERT INTO
  replies (body, question_id, parent_reply_id, user_id)
VALUES
  ('Cool question!',
  (SELECT id FROM questions WHERE body = 'How to make pancakes?'), NULL,
  (SELECT id FROM users WHERE fname = 'Luke' AND lname = 'Skywalker'));

INSERT INTO
  replies (body, question_id, parent_reply_id, user_id)
VALUES
  ('Wow never thought about that',
  (SELECT id FROM questions WHERE body = 'How to make pancakes?'),
  (SELECT id FROM replies WHERE body = 'Cool question!'),
  (SELECT id FROM users WHERE fname = 'James' AND lname = 'Bond'));
  
INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'James' AND lname = 'Bond'),
    (SELECT id FROM questions WHERE body = 'How to make pancakes?')
  );
