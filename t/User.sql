CREATE TABLE "User" (
	-- Globally unique PAMS user ID
	"Id"                SERIAL PRIMARY KEY NOT NULL,

	"Name"			VARCHAR(255) NOT NULL,

	-- Login e-mail address
	"Email"             VARCHAR(255) NOT NULL,

	-- Login password
	"PasswordSalt"      BYTEA NOT NULL,
	"PasswordHash"      BYTEA NOT NULL,

	"Status"		VARCHAR(64) NOT NULL,

	"Type"			VARCHAR(64) NOT NULL
);
