package example

import com.spotify.scio._
import scala.util.Try

/*
sbt "runMain [PACKAGE].WordCount
  --project=[PROJECT] --runner=DataflowRunner --zone=[ZONE]
  --input=gs://dataflow-samples/shakespeare/kinglear.txt
  --output=gs://[BUCKET]/[PATH]/wordcount"
*/

object WordCount {
  case class userRatings(userID: Int, movieID: Int, rating: Long, timestamp: String)

  def getUserRatings(s: String): Option[userRatings] = {
    Try{
      val parsed = s.split(",").toList
      val userID = parsed(0).toInt
      val movieID = parsed(1).toInt
      val rating = parsed(2).toLong
      val timestamp = parsed(3)
      userRatings(userID, movieID, rating, timestamp)
    }.toOption
  }
  def main(cmdlineArgs: Array[String]): Unit = {
    val (sc, args) = ContextAndArgs(cmdlineArgs)

    val exampleData = "/Users/ihanes/GPtest/scio-job/ml-latest-small/ratings.txt"
    val input = args.getOrElse("input", exampleData)
    val output = args("output")

    sc.textFile(input)
      .map(_.trim)
      .flatMap(_.split("[^a-zA-Z']+").filter(_.nonEmpty))
      .countByValue
      .map(t => t._1 + ": " + t._2)
      .saveAsTextFile(output)

    val result = sc.run().waitUntilFinish()
  }
}
