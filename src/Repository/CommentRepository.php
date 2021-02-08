<?php

namespace App\Repository;

/**
 * Repository class for fetching data from the bugdb_comments table.
 */
class CommentRepository
{
    /**
     * Database handler.
     * @var \PDO
     */
    private $dbh;

    /**
     * Class constructor.
     */
    public function __construct(\PDO $dbh)
    {
        $this->dbh = $dbh;
    }

    /**
     * Fetch bug comments
     */
    public function findByBugId(int $id): array
    {
        $sql = 'SELECT c.id, c.email, c.comment, c.comment_type,
                    UNIX_TIMESTAMP(c.ts) AS added,
                    c.reporter_name AS comment_name
                FROM bugdb_comments c
                WHERE c.bug = ?
                GROUP BY c.id ORDER BY c.ts
        ';

        $statement = $this->dbh->prepare($sql);
        $statement->execute([$id]);

        return $statement->fetchAll();
    }

    /**
     * Find all log comments for documentation.
     * TODO: Check if this method is still used in the api.php endpoint.
     */
    public function findDocsComments(int $interval): array
    {
        $sql = "SELECT bugdb_comments.reporter_name, COUNT(*) as count
                FROM bugdb_comments, bugdb
                WHERE comment_type =  'log'
                    AND (package_name IN ('Doc Build problem', 'Documentation problem', 'Translation problem', 'Online Doc Editor problem') OR bug_type = 'Documentation Problem')
                    AND comment LIKE  '%+Status:      Closed</span>%'
                    AND date_sub(curdate(), INTERVAL ? DAY) <= ts
                    AND bugdb.id = bugdb_comments.bug
                GROUP BY bugdb_comments.reporter_name
                ORDER BY count DESC
        ";

        $statement = $this->dbh->prepare($sql);
        $statement->execute([$interval]);

        return $statement->fetchAll();
    }


    public function getCommentById(int $comment_id)
    {
        $sql = <<< SQL
SELECT
  bugdb_comments.id as comment_id,
  bugdb_comments.bug as bug_id,
  bugdb_comments.email,
  bugdb.private    #,
  #bugdb_comments.reporter_name
from
  bugdb_comments
left join
   bugdb
on
   bugdb.id = bugdb_comments.bug
where
  bugdb_comments.comment_type = 'comment' and
  bugdb_comments.id = ?
SQL;

        $statement = $this->dbh->prepare($sql);
        $statement->execute([$comment_id]);

        // No comment found
        $row = $statement->fetch();
        if (!$row) {
            return [
                'error' => "comment_id not found or is not type 'comment'."
            ];
        }

        // don't give out details of private bug reports.
        if ($row['private'] !== 'N') {
            return [
                'comment_id' => $row['comment_id'],
                'bug_id' => $row['bug_id'],
                'error' => 'bug report is private'
            ];
        }

        // Obfuscate the email a bit more than on the webpage
        $protected_email = spam_protect($row['email']);
        $parts = explode(" ", $protected_email);
        if (array_key_exists(0, $parts)) {
            $length = strlen($parts[0]);
            $parts[0] = substr($parts[0], 0, 4);
            $parts[0] = str_pad($parts[0], $length, '.');
        }
        $protected_email = implode(' ', $parts);

        // return the protected data
        return [
            'comment_id' => $row['comment_id'],
            'bug_id' => $row['bug_id'],
            'email' => $protected_email
        ];
    }

    public function getMaxCommentId(): int
    {
        $sql = <<< SQL
SELECT bugdb_comments.id from bugdb_comments
where comment_type = 'comment'
order by bugdb_comments.id desc
limit 1;
SQL;

        $statement = $this->dbh->query($sql);
        $row = $statement->fetch();
        if ($row) {
            return $row["id"];
        }

        return 0;
    }
}
