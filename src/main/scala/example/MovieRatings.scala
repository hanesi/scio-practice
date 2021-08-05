package example

import com.spotify.scio._
import scala.util.Try

/*
sbt "runMain [PACKAGE].WordCount
  --project=[PROJECT] --runner=DataflowRunner --zone=[ZONE]
  --input=gs://dataflow-samples/shakespeare/kinglear.txt
  --output=gs://[BUCKET]/[PATH]/wordcount"
*/

object MovieRatings {
  case class userRatings(userID: Int, movieID: Int, rating: Double, timestamp: String)
  case class movieInfo(movieID: Int, title: String, genres: String)

  def extractRatingInfo(s: String): Option[userRatings] = {
    Try{
      val splitted = s.split(",").map(_.trim).toList
      val userID = splitted(0).toInt
      val movieID = splitted(1).toInt
      val rating = splitted(2).toDouble
      val timestamp = splitted(3)
      userRatings(userID, movieID, rating, timestamp)
    }.toOption
  }

  def extractMovieInfo(s: String): Option[movieInfo] = {
    Try{
      val splitted = s.split(",").map(_.trim).toList
      val movieID = splitted(0).toInt
      val title = splitted(1)
      val genre = splitted(2)
      movieInfo(movieID, title, genre)
    }.toOption
  }

//  def isOutlier(c: Option[(String, Double)]): Boolean = {
//    c._2 > 1
//  }

  def main(cmdlineArgs: Array[String]): Unit = {
    val (sc, args) = ContextAndArgs(cmdlineArgs)

    val exampleData = "/Users/ihanes/GPtest/scio-job/ml-latest-small/ratings.txt"
    val movieData = "/Users/ihanes/GPtest/scio-job/ml-latest-small/movies.txt"
    val input = args.getOrElse("input", exampleData)
    val output = args("output")

    val ratings = sc
      .textFile(input)
      .flatMap(extractRatingInfo)
      .map(userRatings => (userRatings.movieID, userRatings.rating))

    val movies = sc
      .textFile(movieData)
      .flatMap(extractMovieInfo)
      .map(movieInfo => (movieInfo.movieID, movieInfo.title))

    val start = ratings
      .leftOuterJoin(movies)
      .flatMap {
        case (_, (title, Some(rating))) =>
          Option((title, rating))
      }
      .map(x => (x._2, x._1))
      .mapValues(value => (value, 1)) // map entry with a count of 1
      .reduceByKey {
        case ((sumL, countL), (sumR, countR)) =>
          (sumL + sumR, countL + countR)
      }
      .filter(kv => kv._2._2 > 5)
      .mapValues {
        case (sum , count) => sum/count
      }

    start.saveAsTextFile(output)
    val result = sc.run().waitUntilFinish()
  }
}
