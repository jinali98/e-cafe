import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
  QueryCommand,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

export const getStoreStatusHandler = async () => {
  const storeStatus = true;
  return true;
};

export const getStoreCapacityHandler = async () => {
  const capacityStatus = true;
  return true;
};
