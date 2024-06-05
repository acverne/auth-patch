package org.entcore.auth.services.impl;

import fr.wseduc.webutils.Either;
import io.vertx.core.Handler;
import io.vertx.core.eventbus.EventBus;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import org.entcore.common.neo4j.Neo4j;
import org.entcore.common.neo4j.Neo4jResult;
import org.opensaml.saml2.core.Assertion;

public class Canva extends AbstractSSOProvider {
  @Override
  public void execute(Assertion assertion, Handler<Either<String, Object>> handler) {
    handler.handle(new Either.Left<String, Object>("Execute function isn't available on this implementation."));
  }

  private String titleCase(String str) {
    String[] arr = str.toLowerCase().split(" ");
    StringBuffer buffer = new StringBuffer();
    for (int i = 0; i < arr.length; i++) {
      buffer.append(Character.toUpperCase(arr[i].charAt(0)))
        .append(arr[i].substring(1)).append(" ");
    }

    return buffer.toString().trim();
  }
  
  @Override
  public void generate(EventBus eb, String userId, String host, String serviceProviderEntityId, Handler<Either<String, JsonArray>> handler) {
    String query = "MATCH (u:User {id:{userId}})" +
      "-[:IN]->(:Group)-[:AUTHORIZED]->(:Role)-[:AUTHORIZE]->(:Action)<-[:PROVIDE]-(a:Application) " +
      "WHERE a.address STARTS WITH 'https://canva.com/login/sso/' " +
      "RETURN DISTINCT u.email as email, u.firstName AS firstName, u.lastName as lastName";
    
    Neo4j.getInstance().execute(query, new JsonObject().put("userId", userId), Neo4jResult.validUniqueResultHandler(evt -> {
      if (evt.isLeft()) {
        handler.handle(new Either.Left(evt.left().getValue()));
        return;
      }

      JsonArray result = new JsonArray();
      JsonObject user = evt.right().getValue();
      if (user == new JsonObject() || user.getString("email") == null) {
        handler.handle(new Either.Left("invalid.user"));
        return;
      }
      
      result.add(new JsonObject().put("email", user.getString("email", "")));
      result.add(new JsonObject().put("firstName", this.titleCase(user.getString("firstName"))));
      result.add(new JsonObject().put("lastName", this.titleCase(user.getString("lastName"))));
      handler.handle(new Either.Right<>(result));
    }));
  }
}
