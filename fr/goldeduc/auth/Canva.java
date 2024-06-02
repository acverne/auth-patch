package fr.goldeduc.auth;

import fr.wseduc.webutils.Either;
import io.vertx.core.Handler;
import io.vertx.core.eventbus.EventBus;
import io.vertx.core.json.JsonArray;
import io.vertx.core.json.JsonObject;
import org.entcore.auth.services.impl.AbstractSSOProvider;
import org.entcore.common.neo4j.Neo4j;
import org.entcore.common.neo4j.Neo4jResult;
import org.opensaml.saml2.core.Assertion;

public class Canva extends AbstractSSOProvider {
  @Override
  public void execute(Assertion assertion, Handler<Either<String, Object>> handler) {
    handler.handle(new Either.Left<String, Object>("Execute function isn't available on this implementation."));
  }

  public String titleCase(String str) {
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
    String query = "MATCH (u:User {id:{userId}}) RETURN u.profiles as profiles, u.email as email, u.firstName as firstName, u.lastName as lastName";
    Neo4j.getInstance().execute(query, new JsonObject().put("userId", userId), Neo4jResult.validUniqueResultHandler(evt -> {
      if (evt.isLeft()) {
        handler.handle(new Either.Left(evt.left().getValue()));
        return;
      }

      JsonArray result = new JsonArray();
      JsonObject user = evt.right().getValue();
      JsonObject profiles = user.getJsonArray("profiles");
      
      if (!profiles.contains("Personnel") && !profiles.contains("Teacher")) {
        handler.handle(new Either.Left<String, Object>("invalid.user.profile"));
        return;
      }
      
      result.add(new JsonObject().put("email", user.getString("email", "")));
      result.add(new JsonObject().put("firstName", this.titleCase(user.getString("firstName"))));
      result.add(new JsonObject().put("lastName", this.titleCase(user.getString("lastName"))));
      handler.handle(new Either.Right<>(result));
    }));
  }
}
